#!/usr/bin/perl
###############################################################################
#                                                                             #
# IPFire.org - A linux based firewall                                         #
# Copyright (C) 2007  Michael Tremer & Christian Schmidt                      #
#                                                                             #
# This program is free software: you can redistribute it and/or modify        #
# it under the terms of the GNU General Public License as published by        #
# the Free Software Foundation, either version 3 of the License, or           #
# (at your option) any later version.                                         #
#                                                                             #
# This program is distributed in the hope that it will be useful,             #
# but WITHOUT ANY WARRANTY; without even the implied warranty of              #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
# GNU General Public License for more details.                                #
#                                                                             #
# You should have received a copy of the GNU General Public License           #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.       #
#                                                                             #
###############################################################################

use CGI qw(param);

$swroot = "/var/ipfire";

my %cgiparams;
my %mainsettings;
my %proxysettings;

$proxysettings{'NCSA_MIN_PASS_LEN'} = 6;

### Initialize environment
&readhash("${swroot}/main/settings", \%mainsettings);
&readhash("${swroot}/proxy/advanced/settings", \%proxysettings);
$language = $mainsettings{'LANGUAGE'};

### Initialize language
if ($language =~ /^(\w+)$/) {$language = $1;}
 #
 # Uncomment this to force a certain language:
 # $language='en';
 #
require "${swroot}/langs/en.pl";
require "${swroot}/langs/${language}.pl";

my $userdb = "$swroot/proxy/advanced/ncsa/passwd";

&readhash("$swroot/ethernet/settings", \%netsettings);

my $success = 0;

&getcgihash(\%cgiparams);

if ($cgiparams{'SUBMIT'} eq $tr{'advproxy chgwebpwd change password'})
{
	if ($cgiparams{'USERNAME'} eq '')
	{
		$errormessage = $tr{'advproxy errmsg no username'};
		goto ERROR;
	}
	if (($cgiparams{'OLD_PASSWORD'} eq '') || ($cgiparams{'NEW_PASSWORD_1'} eq '') || ($cgiparams{'NEW_PASSWORD_2'} eq ''))
	{
		$errormessage = $tr{'advproxy errmsg no password'};
		goto ERROR;
	}
	if (!($cgiparams{'NEW_PASSWORD_1'} eq $cgiparams{'NEW_PASSWORD_2'}))
	{
		$errormessage = $tr{'advproxy errmsg passwords different'};
		goto ERROR;
	}
	if (length($cgiparams{'NEW_PASSWORD_1'}) < $proxysettings{'NCSA_MIN_PASS_LEN'})
	{
		$errormessage = $tr{'advproxy errmsg password length 1'}.$proxysettings{'NCSA_MIN_PASS_LEN'}.$tr{'advproxy errmsg password length 2'};
		goto ERROR;
	}
	if (! -z $userdb)
	{
		open FILE, $userdb;
		@users = <FILE>;
		close FILE;

		$username = '';
		$cryptpwd = '';

		foreach (@users)
		{
 			chomp;
			@temp = split(/:/,$_);
			if ($temp[0] =~ /^$cgiparams{'USERNAME'}$/i)
			{
				$username = $temp[0];
				$cryptpwd = $temp[1];
			}
		}
	}
	if ($username eq '')
	{
		$errormessage = $tr{'advproxy errmsg invalid user'};
		goto ERROR;
	}
	if (!(crypt($cgiparams{'OLD_PASSWORD'}, $cryptpwd) eq $cryptpwd))
	{
		$errormessage = $tr{'advproxy errmsg password incorrect'};
		goto ERROR;
	}
	$returncode = system("/usr/bin/htpasswd -b $userdb $username $cgiparams{'NEW_PASSWORD_1'}");
	if ($returncode == 0)
	{
		$success = 1;
		undef %cgiparams;
	} else {
		$errormessage = $tr{'advproxy errmsg change fail'};
		goto ERROR;
	}
}

ERROR:

print "Pragma: no-cache\n";
print "Cache-control: no-cache\n";
print "Connection: close\n";
print "Content-type: text/html\n\n";

print <<END
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<title></title>
</head>

<body bgcolor="#FFFFFF">

<center>

<form method='post' action='$ENV{'SCRIPT_NAME'}'>

<table width="80%" cellspacing="10" cellpadding="5" border="0">

<tr>
	<td bgcolor="#C0C0C0">
		<font face="verdana, arial, sans serif" color="#000000" size="2">
		<b>&nbsp;</b>
		</font>
	</td>
</tr>
<tr>
	<td bgcolor="#F4F4F4" align="center">
		<table width="100%" cellspacing="10" cellpadding="10">
		<tr>
			<td nowrap bgcolor="#0050C0" align="center">
			<font face="verdana, arial, sans serif" color="#FFFFFF" size="3">
			<b>$tr{'advproxy chgwebpwd change web password'}</b>
			</font>
			</td>
		</tr>
		<tr>
			<td align="center">
				<table width="70%" cellspacing="7" cellpadding="7">
				<tr>
					<td nowrap bgcolor="#F4F4F4" align="left">
					<font face="verdana, arial, sans serif" color="#000000" size="2">
					<b>$tr{'advproxy chgwebpwd username'}:</b>
					</font>
					</td>
					<td><input type="text" name="USERNAME" value="$cgiparams{'USERNAME'}" size="15"></td>
				</tr>
				<tr>
					<td nowrap bgcolor="#F4F4F4" align="left">
					<font face="verdana, arial, sans serif" color="#000000" size="2">
					<b>$tr{'advproxy chgwebpwd old password'}:</b>
					</font>
					</td>
					<td><input type="password" name="OLD_PASSWORD" value="$cgiparams{'OLD_PASSWORD'}" size="15"></td>
				</tr>
				<tr>
					<td nowrap bgcolor="#F4F4F4" align="left">
					<font face="verdana, arial, sans serif" color="#000000" size="2">
					<b>$tr{'advproxy chgwebpwd new password'}:</b>
					</font>
					</td>
					<td><input type="password" name="NEW_PASSWORD_1" value="$cgiparams{'NEW_PASSWORD_1'}" size="15"></td>
				</tr>
				<tr>
					<td nowrap bgcolor="#F4F4F4" align="left">
					<font face="verdana, arial, sans serif" color="#000000" size="2">
					<b>$tr{'advproxy chgwebpwd new password confirm'}:</b>
					</font>
					</td>
					<td><input type="password" name="NEW_PASSWORD_2" value="$cgiparams{'NEW_PASSWORD_2'}" size="15"></td>
				</tr>
				</table>
				<table width="100%" cellspacing="7" cellpadding="7">
				<tr>
					<td align="center"><br><input type='submit' name='SUBMIT' value="$tr{'advproxy chgwebpwd change password'}"></td>
				</tr>
				</table>
			</td>
		</tr>
END
;

if ($errormessage)
{
	print <<END
	<tr>
		<td nowrap bgcolor="#FF0000" align="center">
		<font face="verdana, arial, sans serif" color="#FFFFFF" size="2">
		<b>$tr{'advproxy chgwebpwd ERROR'}</b> $errormessage
		</font>
		</td>
	</tr>
END
;
}

if ($success)
{
	print <<END
	<tr>
		<td nowrap bgcolor="#00C000" align="center">
		<font face="verdana, arial, sans serif" color="#FFFFFF" size="2">
		<b>$tr{'advproxy chgwebpwd SUCCESS'}</b> $tr{'advproxy errmsg change success'}
		</font>
		</td>
	</tr>
END
;
}


print <<END

	</td>
</tr>
</table>

<tr>
	<td bgcolor="#C0C0C0" align="right">
		<a href="http://www.advproxy.net" target="_blank"><b>
		<font face="verdana,arial,sans serif" color="#FFFFFF" size="1">Advanced Proxy</b></a> running on</font>
		<a href="http://www.ipcop.org" target="_blank"><b>
		<font face="verdana,arial,sans serif" color="#FFFFFF" size="1">IPCop</b></a></font>
	</td>
</tr>

</table>

</form>

</center>

</body>

</html>
END
;

# -------------------------------------------------------------------

sub readhash
{
	my $filename = $_[0];
	my $hash = $_[1];
	my ($var, $val);

	if (-e $filename)
	{
		open(FILE, $filename) or die "Unable to read file $filename";
		while (<FILE>)
		{
			chop;
			($var, $val) = split /=/, $_, 2;
			if ($var)
			{
				$val =~ s/^\'//g;
				$val =~ s/\'$//g;
	
				# Untaint variables read from hash
				$var =~ /([A-Za-z0-9_-]*)/;        $var = $1;
				$val =~ /([\w\W]*)/; $val = $1;
				$hash->{$var} = $val;
			}
		}
		close FILE;
	}
}

# -------------------------------------------------------------------

sub getcgihash
{
	my ($hash, $params) = @_;
	my $cgi = CGI->new ();
	return if ($ENV{'REQUEST_METHOD'} ne 'POST');
	if (!$params->{'wantfile'}) {
		$CGI::DISABLE_UPLOADS = 1;
		$CGI::POST_MAX        = 512 * 1024;
	} else {
		$CGI::POST_MAX = 10 * 1024 * 1024;
	}

	$cgi->referer() =~ m/^https?\:\/\/([^\/]+)/;
	my $referer = $1;
	$cgi->url() =~ m/^https?\:\/\/([^\/]+)/;
	my $servername = $1;
	return if ($referer ne $servername);

	### Modified for getting multi-vars, split by |
	%temp = $cgi->Vars();
	foreach my $key (keys %temp) {
		$hash->{$key} = $temp{$key};
		$hash->{$key} =~ s/\0/|/g;
		$hash->{$key} =~ s/^\s*(.*?)\s*$/$1/;
	}

	if (($params->{'wantfile'})&&($params->{'filevar'})) {
		$hash->{$params->{'filevar'}} = $cgi->upload
					($params->{'filevar'});
	}
	return;
}

# -------------------------------------------------------------------
