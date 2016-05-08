import re
import subprocess
import sys
import os

# Fetching passwords
#
# In order to avoid storing passwords in plain text on the system, they are
# stored in the keychain. Passwords can be managed with:
#
# $ security add-internet-password    -a john.doe@example.com -s imap.gmail.com -w PASSWORD ~/Library/Keychains/login.keychain
# $ security delete-internet-password -a john.doe@example.com -s imap.gmail.com ~/Library/Keychains/login.keychain
#
# Don't forget to remove them from history. If zsh has HIST_IGNORE_SPACE, you
# can just prefix the command with a space to accomplish that.

def keychain_pass(account):
    """
    Fetches the password from the Mac OS X keychain.
    """
    params = {
        'security': '/usr/bin/security',
        'server':   'mutt',
        'account':  account,
        'keychain': os.getenv('HOME') + '/Library/Keychains/login.keychain',
        'user':     os.getenv('USER'),
    }
    command = "sudo -u %(user)s %(security)s -v find-internet-password -g -a %(account)s -s %(server)s %(keychain)s" % params
    output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
    outtext = [l for l in output.splitlines() if l.startswith('password: ')][0]

    return re.match(r'password: "(.*)"', outtext).group(1)

# Gmail foldername mappings
#
# In order to have good naming in local accounts, a mapping needs to be
# established between the names as they appear in Gmail and the ones in the
# local accounts.
#
# Functions are defined in a way that their arguments are the same in both the
# local and the remote repository in .offlineimaprc

mapping = {
    'drafts':  '[Gmail]/Drafts',
    'sent':    '[Gmail]/Sent Mail',
    'flagged': '[Gmail]/Starred',
    'archive': '[Gmail]/All Mail',
    'trash':   '[Gmail]/Trash',
}

local_to_remote_mappings = mapping
remote_to_local_mappings = dict((v, k) for (k, v) in mapping.items())

default_folders = ['INBOX'] + mapping.values()

def gmail_local_to_remote_nametrans(additional=None):
    additional = additional or {}

    def func(folder):
        return additional.get(folder) or \
                local_to_remote_mappings.get(folder) or \
                folder

    return func

def gmail_remote_to_local_nametrans(additional=None):
    additional = additional or {}
    additional = dict((v, k) for (k, v) in additional.items())

    def func(folder):
        return additional.get(folder) or \
                remote_to_local_mappings.get(folder) or \
                folder

    return func

def gmail_folder_filter(*additional):
    allowed = default_folders + list(additional)

    return lambda folder: folder in allowed

# Also used by msmtp to obtain the password
if __name__ == '__main__':
    print keychain_pass(sys.argv[1])
