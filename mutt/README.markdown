# Setting up Mutt

Here be dragons.

Like, real dragons.  Those are not the nice and cuddly "How To Train Your
Dragon" type.  They aren't even the slightly domesticated "Game of Thrones"
version.  They're, like, really bad dragons.  Consider just using a regular
Gmail account.  Save yourself the trouble of reading further.

You have been warned.

# What is this about?

This is a guide on how to setup `mutt` with my dotfiles.  So far, I've used it
only on OS X with Gmail.  The code is not adapted for other platforms yet, but
I might do that once I start using it with something else.  My setup is based
on [Steve Losh's incredible article][the-homely-mutt].  It goes into all the
details and it's worth reading if you want to understand what's going on.
This guide will only cover how to make my dotfiles work.

[the-homely-mutt]: http://stevelosh.com/blog/2012/10/the-homely-mutt/

# Overview

Despite this being called "mutt", it's really a bit more.  One needs to
configure:

- `offlineimap` for fetching emails locally
- `msmtp` for sending emails
- `mutt` itself for browsing those emails
- some additional tools I have use

# Prerequisites

You need to install a bunch of stuff:

```
homebrew install sqlite
homebrew install notmuch
homebrew install offlineimap
homebrew install msmtp
homebrew install goobook
```

You also need a bunch of gems:

```
cd ~/.mutt
gem install maildir mail rdiscount
```

Finally, for mutt itself, you need my tap:

```
brew tap skanev/patches
brew install skanev/patches/mutt
```

# Setting up `offlineimap`

First you need to create a place for your local mails, as `offlineimap` won't
do it for you.

```
mkdir ~/.mail
```

Next, you need to configure `offlineimap`.  There is an example file you can
base your configuration on:

```
cp ~/.mutt/examples/offlineimaprc ~/.offlineimap
```

Follow the comments in the file for details.  You can have multiple accounts,
put I suggest you put all of them under `~/.mail`.

You will also need store passwords in the OS X keychain.  Here's are two
commands to manage that:

```
security add-internet-password    -a john.doe@example.com -s mutt -w PASSWORD ~/Library/Keychains/login.keychain
security delete-internet-password -a john.doe@example.com -s mutt ~/Library/Keychains/login.keychain
```

If you run them, be mindful to not leave your password in the history.  If you
use my zsh configuration, you can accomplish that by putting a space in front
of the command.

Now you can sync up your email.  You can do:

```
offlineimap
```

It will take a while if you have a lot of email.

Finally, you need to schedule this to run automatically.  There is a file that
will do this for you:

```
launchctl load ~/.mutt/support/com.skanev.fetchmail.plist
```

# Setting up msmtp

This one is simpler.  Copy the example over and modify it.

```
cp ~/.mutt/examples/msmtprc ~/.msmtprc
```

Note that the account should have the same name like your profile.

# Setting up mutt

Mutt is already preconfigured.  You just need to specify the default profile
in your `~/.muttrc`:

```
echo source ~/.mutt/profiles/john-doe > ~/.muttrc
```

If you have multiple profiles, these dotfiles have have defined a `mutt`
function that allows you to pass the name of the profile as the first
argument:

```
mutt my-other-profile
```

# Setting up notmuch

`notmuch` is used for full text search.  When installing it, it will ask you for
your mail folder.  Supply `~/.mail` - the `mutt` integration is expecting it.
You can make it work just by:

```
brew install notmuch
notmuch setup
notmuch new
```

# Setting up goobook

This is quite annoying.  Create a profile based on the example:

```
cp ~/.mutt/examples/goobook ~/.goobookrc.john-doe
```

Then authenticate it:

```
goobook -c ~/.goobookrc.john-doe authenticate
```

Again, it's important to replace `john-doe` with your profile name, as the
mutt settings depend on it.

# You're done

Yeah, that was it.
