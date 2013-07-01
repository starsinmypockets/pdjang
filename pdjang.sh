#! /bin/bash
# Installs django into virtual environment with dependencies
# Paul Walker <starsinmypockets@gmail.com>
# 
# Forked from django-bone
# # Justine Tunney <jtunney@lobstertech.com>
# Licensed MIT
#

# If no arguments, print usage statement & exit from function
[[ -n "$1" ]] || { echo "Usage: pdjang.sh projectname"; exit 0 ; }
# Else, continue and print the arguments

# Define a bunch of silly variables
proj=$1
projRoot="/srv/www/py-proj"
envName="$1-env"
envDir="$projRoot/$envName"
projName="$1_proj"
projDir="$envDir/$projName"
projAppDir="$projDir/$projName"
mainAppDir="$projDir/main"
adminEmail="starsinmypockets@gmail.com"

# Install virtualenv
cd $projRoot
echo "Installing Python virtual environment at $projRoot/$envName"
virtualenv $envName
echo "$envDir"

# Activate virtualenv
echo "Activating virtualenv"
cd $envDir/bin
chmod 750 ./activate
./activate

# Install Django & dependencies
echo "Installing Django..."
$envDir/bin/pip install django
mkdir $projDir
echo "Creating django project at $projDir"
$envDir/bin/django-admin.py startproject $projName $projDir
echo "Updating ./manage.py..."
`sed -i "s_^#.*_#! ../bin/python_g" $projDir/manage.py`
chmod 750 $projDir/manage.py
echo "Installing South..."
$envDir/bin/easy_install south
echo "Installing Python Image Library..."
$envDir/bin/easy_install PIL

# Create static, template and media directories, log directory etc
echo "Creating directory static file directories..."
mkdir $projAppDir/static
mkdir $projAppDir/static/css
mkdir $projAppDir/static/js
mkdir $projAppDir/static/images
mkdir $projAppDir/logs
echo "Creating directory: $projAppDir/templates..."
mkdir $projAppDir/templates
echo "Creating directory: $projAppDir/media..."
mkdir $projAppDir/media

# Install twitter bootstrap
echo "Installing twitter bootstrap..."
wget -P $projAppDir/static http://twitter.github.com/bootstrap/assets/bootstrap.zip
cd $projAppDir/static
unzip "$projAppDir/static/bootstrap.zip"
rm "$projAppDir/static/bootstrap.zip"
wget -P $projAppDir/static/js http://code.jquery.com/jquery-1.8.3.min.js

# Install django debug toolbar
echo "Installing Django debug toolbar..."
$envDir/bin/easy_install django-debug-toolbar

# create "main" app
cd $projDir
./manage.py startapp main

##############
# settings.py
##############
echo "Generating settings.py..."
cat >$projAppDir/settings.py <<EOF

# Django settings for $proj

DEBUG = True

def cust_tool_callback(request):
	return DEBUG

DEBUG_TOOLBAR_CONFIG = {
	'SHOW_TOOLBAR_CALLBACK' : cust_tool_callback,
}

TEMPLATE_DEBUG = DEBUG

ADMINS = (
    # ('Your Name', 'your_email@example.com'),
)

MANAGERS = ADMINS

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '$projName.sqlite3',
    }
}
LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'standard': {
            'format' : "[%(asctime)s] %(levelname)s [%(name)s:%(lineno)s] %(message)s",
            'datefmt' : "%d/%b/%Y %H:%M:%S"
        },
    },
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse',
        },
    },
    'handlers': {
        'null': {
            'level':'DEBUG',
            'class':'django.utils.log.NullHandler',
        },
        'logfile': {
            'level':'DEBUG',
            'class':'logging.handlers.RotatingFileHandler',
            'filename': '$projAppDir/logs/logfile.log',
            'maxBytes': 50000,
            'backupCount': 2,
            'formatter': 'standard',
        },
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['null'],
            'level': 'DEBUG',
            'propagate': False,
        },
        '': {
            'handlers': ['logfile',],
            'level': 'DEBUG',
            'formatter': 'standard',
        },
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# In a Windows environment this must be set to your system time zone.
TIME_ZONE = 'America/New_York'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale.
USE_L10N = True

# If you set this to False, Django will not use timezone-aware datetimes.
USE_TZ = True

# Absolute filesystem path to the directory that will hold user-uploaded files.
# Example: "/home/media/media.lawrence.com/media/"
MEDIA_ROOT = '$projAppDir/media'

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash.
# Examples: "http://media.lawrence.com/media/", "http://example.com/media/"
MEDIA_URL = ''

# Absolute path to the directory static files should be collected to.
# Don't put anything in this directory yourself; store your static files
# in apps' "static/" subdirectories and in STATICFILES_DIRS.
# Example: "/home/media/media.lawrence.com/static/"

# @@ PARAM
STATIC_ROOT = ''

# URL prefix for static files.
# Example: "http://media.lawrence.com/static/"
STATIC_URL = '/static/'

# Additional locations of static files
STATICFILES_DIRS = (
		'$projAppDir/static',
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

# List of finder classes that know how to find static files in
# various locations.
STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
#    'django.contrib.staticfiles.finders.DefaultStorageFinder',
)

# Make this unique, and don't share it with anybody.
SECRET_KEY = '229xr!_p8!!$q+yn$)zrso*lx1b4)77le_8pedli%wm0u=c5ov'

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
#     'django.template.loaders.eggs.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'debug_toolbar.middleware.DebugToolbarMiddleware',
    # Uncomment the next line for simple clickjacking protection:
    # 'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

# @@PARAM
ROOT_URLCONF = '$projName.urls'

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = '$projName.wsgi.application'

TEMPLATE_DIRS = (
    '$projAppDir/templates'
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
)

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.admin',
    'south',
    'debug_toolbar',
    # Uncomment the next line to enable admin documentation:
    # 'django.contrib.admindocs',
)

EOF

############
# urls.py
############
echo "Generating urls.py..."
cat >$projAppDir/urls.py <<EOF
from django.conf.urls import patterns, include, url
from django.views.generic import TemplateView
import settings
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', TemplateView.as_view(template_name="home.html")),
    url(r'^test$', TemplateView.as_view(template_name="test.html")),
    url(r'^bootstrap$', TemplateView.as_view(template_name="bootstrap.html")),
    url(r'^admin/', include(admin.site.urls)),
    url(r'test-log/', 'main.views.test_logging', name='test_logging'),
)

#serve static files in development
if settings.DEBUG:
	urlpatterns += patterns('',
	url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {
		'document_root': '~/py-proj/go-env/go_proj/go_proj/static/' #settings.STATIC_ROOT,
		}),
	)
EOF

############
# views.py
############
echo "Generating views.py..."
cat >$mainAppDir/views.py <<EOF
from django.shortcuts import render, render_to_response
from django.http import HttpResponse
from django.template import Context, loader, RequestContext
import logging

logger = logging.getLogger(__name__)

def test_logging(request):
	logger.debug('Logging works!')
	return HttpResponse('Go check the logs')
EOF

############
# base.html
############
echo "Generating base.html template..."
cat >$projAppDir/templates/base.html <<EOF
<head>
	<script type="text/javascript" src="{{ STATIC_URL }}bootstrap/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="{{ STATIC_URL }}js/jquery-1.8.3.min.js"></script>
	<link rel="stylesheet" type="text/css" href="{{ STATIC_URL }}bootstrap/css/bootstrap.min.css" />
</head>
<body>
	<h1>Hello site template</h1>
	{% block content %}

	{% endblock %}
</body>
EOF

############
# home.html
############
echo "Generating home.html template..."
cat >$projAppDir/templates/home.html <<EOF

{% extends "base.html" %}

{% block content %}
	<h2>Home page content</h2>
{% endblock %}
EOF


############
# test.html
############
echo "Generating test.html template..."
cat >$projAppDir/templates/test.html <<EOF

{% extends "base.html" %}

{% block content %}
<!-- Sample Content to Plugin to Template -->
<h1>CSS Basic Elements</h1>

<p>The purpose of this HTML is to help determine what default settings are with CSS and to make sure that all possible HTML Elements are included in this HTML so as to not miss any possible Elements when designing a site.</p>

<hr />

<h1 id="headings">Headings</h1>

<h1>Heading 1</h1>
<h2>Heading 2</h2>
<h3>Heading 3</h3>
<h4>Heading 4</h4>
<h5>Heading 5</h5>
<h6>Heading 6</h6>

<small><a href="#wrapper">[top]</a></small>
<hr />


<h1 id="paragraph">Paragraph</h1>

<img style="width:250px;height:125px;float:right" src="images/css_gods_language.png" alt="CSS | God's Language" />
<p>Lorem ipsum dolor sit amet, <a href="#" title="test link">test link</a> adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus. Maecenas ornare tortor. Donec sed tellus eget sapien fringilla nonummy. Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.</p>

<p>Lorem ipsum dolor sit amet, <em>emphasis</em> consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus. Maecenas ornare tortor. Donec sed tellus eget sapien fringilla nonummy. Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.</p>

<small><a href="#wrapper">[top]</a></small>
<hr />

<h1 id="list_types">List Types</h1>

<h3>Definition List</h3>
<dl>
	<dt>Definition List Title</dt>
	<dd>This is a definition list division.</dd>
</dl>

<h3>Ordered List</h3>
<ol>
	<li>List Item 1</li>
	<li>List Item 2</li>
	<li>List Item 3</li>
</ol>

<h3>Unordered List</h3>
<ul>
	<li>List Item 1</li>
	<li>List Item 2</li>
	<li>List Item 3</li>
</ul>

<small><a href="#wrapper">[top]</a></small>
<hr />

<h1 id="form_elements">Fieldsets, Legends, and Form Elements</h1>

<fieldset>
	<legend>Legend</legend>

	<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus.</p>

	<form>
		<h2>Form Element</h2>

		<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui.</p>

		<p><label for="text_field">Text Field:</label><br />
		<input type="text" id="text_field" /></p>

		<p><label for="text_area">Text Area:</label><br />
		<textarea id="text_area"></textarea></p>

		<p><label for="select_element">Select Element:</label><br />
			<select name="select_element">
			<optgroup label="Option Group 1">
				<option value="1">Option 1</option>
				<option value="2">Option 2</option>
				<option value="3">Option 3</option>
			</optgroup>
			<optgroup label="Option Group 2">
				<option value="1">Option 1</option>
				<option value="2">Option 2</option>
				<option value="3">Option 3</option>
			</optgroup>
		</select></p>

		<p><label for="radio_buttons">Radio Buttons:</label><br />
			<input type="radio" class="radio" name="radio_button" value="radio_1" /> Radio 1<br/>
				<input type="radio" class="radio" name="radio_button" value="radio_2" /> Radio 2<br/>
				<input type="radio" class="radio" name="radio_button" value="radio_3" /> Radio 3<br/>
		</p>

		<p><label for="checkboxes">Checkboxes:</label><br />
			<input type="checkbox" class="checkbox" name="checkboxes" value="check_1" /> Radio 1<br/>
				<input type="checkbox" class="checkbox" name="checkboxes" value="check_2" /> Radio 2<br/>
				<input type="checkbox" class="checkbox" name="checkboxes" value="check_3" /> Radio 3<br/>
		</p>

		<p><label for="password">Password:</label><br />
			<input type="password" class="password" name="password" />
		</p>

		<p><label for="file">File Input:</label><br />
			<input type="file" class="file" name="file" />
		</p>


		<p><input class="button" type="reset" value="Clear" /> <input class="button" type="submit" value="Submit" />
		</p>



	</form>

</fieldset>

<small><a href="#wrapper">[top]</a></small>
<hr />

<h1 id="tables">Tables</h1>

<table cellspacing="0" cellpadding="0">
	<tr>
		<th>Table Header 1</th><th>Table Header 2</th><th>Table Header 3</th>
	</tr>
	<tr>
		<td>Division 1</td><td>Division 2</td><td>Division 3</td>
	</tr>
	<tr class="even">
		<td>Division 1</td><td>Division 2</td><td>Division 3</td>
	</tr>
	<tr>
		<td>Division 1</td><td>Division 2</td><td>Division 3</td>
	</tr>

</table>

<small><a href="#wrapper">[top]</a></small>
<hr />

<h1 id="misc">Misc Stuff - abbr, acronym, pre, code, sub, sup, etc.</h1>

<p>Lorem <sup>superscript</sup> dolor <sub>subscript</sub> amet, consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. <cite>cite</cite>. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus. Maecenas ornare tortor. Donec sed tellus eget sapien fringilla nonummy. <acronym title="National Basketball Association">NBA</acronym> Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.  <abbr title="Avenue">AVE</abbr></p>

<pre><p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nullam dignissim convallis est. Quisque aliquam. Donec faucibus. Nunc iaculis suscipit dui. Nam sit amet sem. Aliquam libero nisi, imperdiet at, tincidunt nec, gravida vehicula, nisl. Praesent mattis, massa quis luctus fermentum, turpis mi volutpat justo, eu volutpat enim diam eget metus. Maecenas ornare tortor. Donec sed tellus eget sapien fringilla nonummy. <acronym title="National Basketball Association">NBA</acronym> Mauris a ante. Suspendisse quam sem, consequat at, commodo vitae, feugiat in, nunc. Morbi imperdiet augue quis tellus.  <abbr title="Avenue">AVE</abbr></p></pre>

<blockquote>
	"This stylesheet is going to help so freaking much." <br />-Blockquote
</blockquote>

<small><a href="#wrapper">[top]</a></small>
<!-- End of Sample Content -->
{% endblock %}
EOF

# Create admin account
cd $projDir
./manage.py syncdb
# /usr/bin/expect <<EOD
# spawn ./manage.py syncdb
# expect "Would you like to create one now? (yes/no):"
# send "yes\n"
# expect "Username (leave blank to use 'root'):"
# send "admin\n"
# expect "E-mail address:"
# send $email
# expect "Password:"
# send $pass
# expect "Password (again):"
# send "securish123\n"
# expect eof {exit}
# interact
# EOD