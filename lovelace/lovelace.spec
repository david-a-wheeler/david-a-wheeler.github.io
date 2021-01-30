#This file is copyright 1999 Aidan Skinner, you are granted use of it
#under the GNU General Public Licence version 2 or later, available
#from http://www.gnu.org

%define VERSION_MAJOR 0
%define VERSION_MINOR 0
%define RELEASE       1

Summary: #a brief (<60 chars) description

Name: lovelace

Version: %{VERSION_MAJOR}.%{VERSION_MINOR}

Release: %{RELEASE}

Source: #tarball of the html files 

Copyright: #the licence that lovelace is under

Group: Documentation

Prefix: /usr/doc/Ada #this is a suggestion, based on where I've put
		     #the LRM and the style guide

Packager: #your name here

Vendor: #the vendor

%description 
a brief description of lovelace should go here, a few lines long


%prep 
%setup 

%build

%install
#make sure that the appropriate directorys are present, change these
#if your moving it elsewhere
mkdir usr
mkdir usr/doc
mkdir usr/doc/Ada
mkdir usr/doc/Ada/lovelace/

#copy the files from the current directory to wherever
cp -r *.htm *.gif usr/doc/Ada/lovelace

%files
/usr/doc/Ada/lovelace


