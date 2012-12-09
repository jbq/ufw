'''backend.py: interface for ufw backends'''
#
# Copyright 2008-2011 Canonical Ltd.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3,
#    as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

import errno
import os
import re
import stat
import sys
import ufw.util
from ufw.util import warn, debug
from ufw.common import UFWError, config_dir, iptables_dir, UFWRule
import ufw.applications

class UFWBackend:
    '''Interface for backends'''
    def __init__(self, name, dryrun, extra_files=None):
        self.defaults = None
        self.name = name
        self.dryrun = dryrun
        self.rules = []
        self.rules6 = []

        self.files = {'defaults': os.path.join(config_dir, 'default/ufw'),
                      'conf': os.path.join(config_dir, 'ufw/ufw.conf'),
                      'apps': os.path.join(config_dir, 'ufw/applications.d') }
        if extra_files != None:
            self.files.update(extra_files)

        self.loglevels = {'off':       0,
                          'low':     100,
                          'medium':  200,
                          'high':    300,
                          'full':    400 }

        self.do_checks = True
        try:
            self._do_checks()
            self._get_defaults()
            self._read_rules()
        except Exception:
            raise

        self.profiles = ufw.applications.get_profiles(self.files['apps'])

        self.iptables = os.path.join(iptables_dir, "iptables")
        self.iptables_restore = os.path.join(iptables_dir, "iptables-restore")
        self.ip6tables = os.path.join(iptables_dir, "ip6tables")
        self.ip6tables_restore = os.path.join(iptables_dir, \
                                              "ip6tables-restore")

        self.iptables_version = ufw.util.get_iptables_version(self.iptables)

    def is_enabled(self):
        '''Is firewall configured as enabled'''
        if self.defaults.has_key('enabled') and \
           self.defaults['enabled'] == 'yes':
            return True
        return False

    def use_ipv6(self):
        '''Is firewall configured to use IPv6'''
        if self.defaults.has_key('ipv6') and \
           self.defaults['ipv6'] == 'yes' and \
           os.path.exists("/proc/sys/net/ipv6"):
            return True
        return False

    def _get_default_policy(self, primary="input"):
        '''Get default policy for specified primary chain'''
        policy = "default_" + primary + "_policy"

        rstr = ""
        if self.defaults[policy] == "accept":
            rstr = "allow"
        elif self.defaults[policy] == "accept_no_track":
            rstr = "allow-without-tracking"
        elif self.defaults[policy] == "reject":
            rstr = "reject"
        else:
            rstr = "deny"

        return rstr

    def _do_checks(self):
        '''Perform basic security checks:
        is setuid or setgid (for non-Linux systems)
        checks that script is owned by root
        checks that every component in absolute path are owned by root
        warn if script is group writable
        warn if part of script path is group writable

        Doing this at the beginning causes a race condition with later
        operations that don't do these checks.  However, if the user running
        this script is root, then need to be root to exploit the race
        condition (and you are hosed anyway...)
        '''

        if not self.do_checks:
            err_msg = _("Checks disabled")
            warn(err_msg)
            return True

        # Not needed on Linux, but who knows the places we will go...
        if os.getuid() != os.geteuid():
            err_msg = _("ERROR: this script should not be SUID")
            raise UFWError(err_msg)
        if os.getgid() != os.getegid():
            err_msg = _("ERROR: this script should not be SGID")
            raise UFWError(err_msg)
        uid = os.getuid()

        if uid != 0:
            err_msg = _("You need to be root to run this script")
            raise UFWError(err_msg)

        # Use these so we only warn once
        warned_world_write = {}
        warned_group_write = {}
        warned_owner = {}

        profiles = []
        if not os.path.isdir(self.files['apps']):
            warn_msg = _("'%s' does not exist") % (self.files['apps'])
            warn(warn_msg)
        else:
            pat = re.compile(r'^\.')
            for profile in os.listdir(self.files['apps']):
                if not pat.search(profile):
                    profiles.append(os.path.join(self.files['apps'], profile))

        for path in self.files.values() + [ os.path.abspath(sys.argv[0]) ] + \
                profiles:
            while True:
                debug("Checking " + path)
                if path == self.files['apps'] and \
                           not os.path.isdir(self.files['apps']):
                    break

                try:
                    statinfo = os.stat(path)
                    mode = statinfo[stat.ST_MODE]
                except OSError:
                    err_msg = _("Couldn't stat '%s'") % (path)
                    raise UFWError(err_msg)
                except Exception:
                    raise

                if statinfo.st_uid != 0 and not warned_owner.has_key(path):
                    warn_msg = _("uid is %(uid)s but '%(path)s' is owned by " \
                                 "%(st_uid)s") % ({'uid': str(uid), \
                                               'path': path, \
                                               'st_uid': str(statinfo.st_uid)})
                    warn(warn_msg)
                    warned_owner[path] = True
                if mode & stat.S_IWOTH and not warned_world_write.has_key(path):
                    warn_msg = _("%s is world writable!") % (path)
                    warn(warn_msg)
                    warned_world_write[path] = True
                if mode & stat.S_IWGRP and not warned_group_write.has_key(path):
                    warn_msg = _("%s is group writable!") % (path)
                    warn(warn_msg)
                    warned_group_write[path] = True

                if path == "/":
                    break

                path = os.path.dirname(path)
                if not path:
                    raise OSError(errno.ENOENT, "Could not find '%s'" % (path))

        for f in self.files:
            if f != 'apps' and not os.path.isfile(self.files[f]):
                err_msg = _("'%(f)s' file '%(name)s' does not exist") % \
                           ({'f': f, 'name': self.files[f]})
                raise UFWError(err_msg)

    def _get_defaults(self):
        '''Get all settings from defaults file'''
        self.defaults = {}
        for f in [self.files['defaults'], self.files['conf']]:
            try:
                orig = ufw.util.open_file_read(f)
            except Exception:
                err_msg = _("Couldn't open '%s' for reading") % (f)
                raise UFWError(err_msg)
            pat = re.compile(r'^\w+="?\w+"?')
            for line in orig:
                if pat.search(line):
                    tmp = re.split(r'=', line.strip())
                    self.defaults[tmp[0].lower()] = tmp[1].lower().strip('"\'')

            orig.close()

        # do some default policy sanity checking
        policies = ['accept', 'accept_no_track', 'drop', 'reject']
        for c in [ 'input', 'output', 'forward' ]:
            if not self.defaults.has_key('default_%s_policy' % (c)):
                err_msg = _("Missing policy for '%s'" % (c))
                raise UFWError(err_msg)
            p = self.defaults['default_%s_policy' % (c)]
            if p not in policies or \
               (p == 'accept_no_track' and c == 'forward'):
                err_msg = _("Invalid policy '%(policy)s' for '%(chain)s'" % \
                            ({'policy': p, 'chain': c}))
                raise UFWError(err_msg)

    def set_default(self, fn, opt, value):
        '''Sets option in defaults file'''
        if not re.match(r'^[\w_]+$', opt):
            err_msg = _("Invalid option")
            raise UFWError(err_msg)

        # Perform this here so we can present a nice error to the user rather
        # than a traceback
        if not os.access(fn, os.W_OK):
            err_msg = _("'%s' is not writable" % (fn))
            raise UFWError(err_msg)

        try:
            fns = ufw.util.open_files(fn)
        except Exception:
            raise
        fd = fns['tmp']

        found = False
        pat = re.compile(r'^' + opt + '=')
        for line in fns['orig']:
            if pat.search(line):
                ufw.util.write_to_file(fd, opt + "=" + value + "\n")
                found = True
            else:
                ufw.util.write_to_file(fd, line)

        # Add the entry if not found
        if not found:
            ufw.util.write_to_file(fd, opt + "=" + value + "\n")

        try:
            ufw.util.close_files(fns)
        except Exception:
            raise

        # Now that the files are written out, update value in memory
        self.defaults[opt.lower()] = value.lower().strip('"\'')

    def set_default_application_policy(self, policy):
        '''Sets default application policy of firewall'''
        if not self.dryrun:
            if policy == "allow":
                try:
                    self.set_default(self.files['defaults'], \
                                            "DEFAULT_APPLICATION_POLICY", \
                                            "\"ACCEPT\"")
                except Exception:
                    raise
            elif policy == "deny":
                try:
                    self.set_default(self.files['defaults'], \
                                            "DEFAULT_APPLICATION_POLICY", \
                                            "\"DROP\"")
                except Exception:
                    raise
            elif policy == "reject":
                try:
                    self.set_default(self.files['defaults'], \
                                            "DEFAULT_APPLICATION_POLICY", \
                                            "\"REJECT\"")
                except Exception:
                    raise
            elif policy == "skip":
                try:
                    self.set_default(self.files['defaults'], \
                                            "DEFAULT_APPLICATION_POLICY", \
                                            "\"SKIP\"")
                except Exception:
                    raise
            else:
                err_msg = _("Unsupported policy '%s'") % (policy)
                raise UFWError(err_msg)

        rstr = _("Default application policy changed to '%s'") % (policy)

        return rstr

    def get_app_rules_from_template(self, template):
        '''Return a list of UFWRules based on the template rule'''
        rules = []
        profile_names = self.profiles.keys()

        if template.dport in profile_names and template.sport in profile_names:
            dports = ufw.applications.get_ports(self.profiles[template.dport])
            sports = ufw.applications.get_ports(self.profiles[template.sport])
            for i in dports:
                tmp = template.dup_rule()
                tmp.dapp = ""
                tmp.set_port("any", "src")
                try:
                    (port, proto) = ufw.util.parse_port_proto(i)
                    tmp.set_protocol(proto)
                    tmp.set_port(port, "dst")
                except Exception:
                    raise

                tmp.dapp = template.dapp

                if template.dport == template.sport:
                    # Just use the same ports as dst for src when they are the
                    # same to avoid duplicate rules
                    tmp.sapp = ""
                    try:
                        (port, proto) = ufw.util.parse_port_proto(i)
                        tmp.set_protocol(proto)
                        tmp.set_port(port, "src")
                    except Exception:
                        raise

                    tmp.sapp = template.sapp
                    rules.append(tmp)
                else:
                    for j in sports:
                        rule = tmp.dup_rule()
                        rule.sapp = ""
                        try:
                            (port, proto) = ufw.util.parse_port_proto(j)
                            rule.set_protocol(proto)
                            rule.set_port(port, "src")
                        except Exception:
                            raise

                        if rule.protocol == "any":
                            rule.set_protocol(tmp.protocol)

                        rule.sapp = template.sapp
                        rules.append(rule)
        elif template.sport in profile_names:
            for p in ufw.applications.get_ports(self.profiles[template.sport]):
                rule = template.dup_rule()
                rule.sapp = ""
                try:
                    (port, proto) = ufw.util.parse_port_proto(p)
                    rule.set_protocol(proto)
                    rule.set_port(port, "src")
                except Exception:
                    raise

                rule.sapp = template.sapp
                rules.append(rule)
        elif template.dport in profile_names:
            for p in ufw.applications.get_ports(self.profiles[template.dport]):
                rule = template.dup_rule()
                rule.dapp = ""
                try:
                    (port, proto) = ufw.util.parse_port_proto(p)
                    rule.set_protocol(proto)
                    rule.set_port(port, "dst")
                except Exception:
                    raise

                rule.dapp = template.dapp
                rules.append(rule)

        if len(rules) < 1:
            err_msg = _("No rules found for application profile")
            raise UFWError(err_msg)

        return rules

    def update_app_rule(self, profile):
        '''Update rule for profile in place. Returns result string and bool
           on whether or not the profile is used in the current ruleset.
        '''
        updated_rules = []
        updated_rules6 = []
        last_tuple = ""
        rstr = ""
        updated_profile = False

        # Remember, self.rules is from user[6].rules, and not the running
        # firewall.
        for r in self.rules + self.rules6:
            if r.dapp == profile or r.sapp == profile:
                # We assume that the rules are in app rule order. Specifically,
                # if app rule has multiple rules, they are one after the other.
                # If the rule ordering changes, the below will have to change.
                tupl = r.get_app_tuple()
                if tupl == last_tuple:
                    # Skip the rule if seen this tuple already (ie, it is part
                    # of a known tuple).
                    continue
                else:
                    # Have a new tuple, so find and insert new app rules here
                    template = r.dup_rule()
                    template.set_protocol("any")
                    if template.dapp != "":
                        template.set_port(template.dapp, "dst")
                    if template.sapp != "":
                        template.set_port(template.sapp, "src")
                    try:
                        new_app_rules = self.get_app_rules_from_template(\
                                          template)
                    except Exception:
                        raise

                    for new_r in new_app_rules:
                        new_r.normalize()
                        if new_r.v6:
                            updated_rules6.append(new_r)
                        else:
                            updated_rules.append(new_r)

                    last_tuple = tupl
                    updated_profile = True
            else:
                if r.v6:
                    updated_rules6.append(r)
                else:
                    updated_rules.append(r)

        if updated_profile:
            self.rules = updated_rules
            self.rules6 = updated_rules6
            rstr += _("Rules updated for profile '%s'") % (profile)

            try:
                self._write_rules(False) # ipv4
                self._write_rules(True) # ipv6
            except Exception:
                err_msg = _("Couldn't update application rules")
                raise UFWError(err_msg)

        return (rstr, updated_profile)

    def find_application_name(self, profile_name):
        '''Find the application profile name for profile_name'''
        if self.profiles.has_key(profile_name):
            return profile_name

        match = ""
        matches = 0
        for n in self.profiles.keys():
            if n.lower() == profile_name.lower():
                match = n
                matches += 1

        debug_msg = "'%d' matches for '%s'" % (matches, profile_name)
        debug(debug_msg)
        if matches == 1:
            return match
        elif matches > 1:
            err_msg = _("Found multiple matches for '%s'. Please use exact profile name") % \
                        (profile_name)
        err_msg = _("Could not find a profile matching '%s'") % (profile_name)
        raise UFWError(err_msg)

    def find_other_position(self, position, v6):
        '''Return the absolute position in the other list of the rule with the
	   user position of the given list. For example, find_other_position(4,
	   True) will return the absolute position of the rule in the ipv4 list
           matching the user specified '4' rule in the ipv6 list.
        '''
        # Invalid search (v6 rule with too low position)
        if v6 and position > len(self.rules6):
            raise ValueError()

        # Invalid search (v4 rule with too high position)
        if not v6 and position > len(self.rules):
            raise ValueError()

        if position < 1:
            raise ValueError()

        rules = []
        if v6:
            rules = self.rules6
        else:
            rules = self.rules

        # self.rules[6] is a list of tuples. Some application rules have
        # multiple tuples but the user specifies by ufw rule, not application
        # tuple, so we need to find how many tuples there are leading up to
        # the specified position, which we can then use as an offset for
        # getting the proper match_rule.
        app_rules = {}
        tuple_offset = 0
        for i, r in enumerate(rules):
            if i >= position:
                break
            tupl = ""
            if r.dapp != "" or r.sapp != "":
                tupl = r.get_app_tuple()

                if app_rules.has_key(tupl):
                    tuple_offset += 1
                else:
                    app_rules[tupl] = True

        rules = []
        if v6:
            rules = self.rules
            match_rule = self.rules6[position - 1 + tuple_offset].dup_rule()
            match_rule.set_v6(False)
        else:
            rules = self.rules6
            match_rule = self.rules[position - 1 + tuple_offset].dup_rule()
            match_rule.set_v6(True)

        count = 1
        for r in rules:
            if UFWRule.match(r, match_rule) == 0:
                return count
            count += 1

        return 0

    def get_loglevel(self):
        '''Gets current log level of firewall'''
        level = 0
        rstr = _("Logging: ")
        if not self.defaults.has_key('loglevel') or \
           self.defaults['loglevel'] not in self.loglevels.keys():
            level = -1
            rstr += _("unknown")
        else:
            level = self.loglevels[self.defaults['loglevel']]
            if level == 0:
                rstr += "off"
            else:
                rstr += "on (%s)" % (self.defaults['loglevel'])
        return (level, rstr)

    def set_loglevel(self, level):
        '''Sets log level of firewall'''
        if level not in self.loglevels.keys() + ['on']:
            err_msg = _("Invalid log level '%s'") % (level)
            raise UFWError(err_msg)

        new_level = level
        if level == "on":
            if not self.defaults.has_key('loglevel') or \
               self.defaults['loglevel'] == "off":
                new_level = "low"
            else:
                new_level = self.defaults['loglevel']

        try:
            self.set_default(self.files['conf'], "LOGLEVEL", new_level)
            self.update_logging(new_level)
        except Exception:
            raise

        if new_level == "off":
            return _("Logging disabled")
        else:
            return _("Logging enabled")

    def get_rules(self):
        '''Return list of all rules'''
        return self.rules + self.rules6

    def get_rules_count(self, v6):
        '''Return number of ufw rules (not iptables rules)'''
        rules = []
        if v6:
            rules = self.rules6
        else:
            rules = self.rules

        count = 0
        app_rules = {}
        for r in rules:
            tupl = ""
            if r.dapp != "" or r.sapp != "":
                tupl = r.get_app_tuple()

                if app_rules.has_key(tupl):
                    debug("Skipping found tuple '%s'" % (tupl))
                    continue
                else:
                    app_rules[tupl] = True
            count += 1

        return count

    def get_rule_by_number(self, num):
        '''Return rule specified by number seen via "status numbered"'''
        rules = self.get_rules()

        count = 1
        app_rules = {}
        for r in rules:
            tupl = ""
            if r.dapp != "" or r.sapp != "":
                tupl = r.get_app_tuple()

                if app_rules.has_key(tupl):
                    debug("Skipping found tuple '%s'" % (tupl))
                    continue
                else:
                    app_rules[tupl] = True
            if count == int(num):
                return r
            count += 1

        return None

    def get_matching(self, rule):
        '''See if there is a matching rule in the existing ruleset. Note this
           does not group rules by tuples.'''
        matched = []
        count = 0
        for r in self.get_rules():
            count += 1
            ret = rule.fuzzy_dst_match(r)
            if ret < 1:
                matched.append(count)

        return matched

    # API overrides
    def set_default_policy(self, policy, direction):
        '''Set default policy for specified direction'''
        raise UFWError("UFWBackend.set_default_policy: need to override")

    def get_running_raw(self, rules_type):
        '''Get status of running firewall'''
        raise UFWError("UFWBackend.get_running_raw: need to override")

    def get_status(self, verbose, show_count):
        '''Get managed rules'''
        raise UFWError("UFWBackend.get_status: need to override")

    def set_rule(self, rule, allow_reload):
        '''Update firewall with rule'''
        raise UFWError("UFWBackend.set_rule: need to override")

    def start_firewall(self):
        '''Start the firewall'''
        raise UFWError("UFWBackend.start_firewall: need to override")

    def stop_firewall(self):
        '''Stop the firewall'''
        raise UFWError("UFWBackend.stop_firewall: need to override")

    def get_app_rules_from_system(self, template, v6):
        '''Get a list if rules based on template'''
        raise UFWError("UFWBackend.get_app_rules_from_system: need to " + \
                       "override")

    def update_logging(self, level):
        '''Update loglevel of running firewall'''
        raise UFWError("UFWBackend.update_logging: need to override")

    def reset(self):
        '''Reset the firewall'''
        raise UFWError("UFWBackend.reset: need to override")
