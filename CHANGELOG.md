### 2.0.1 - 2017-05-16

* Refactored to simplify some logic and start moving toward mimicking default Devise lifecycle behavior
* Added `Devise::MultiEmail.only_login_with_primary_email` option to restrict login to only primary emails
* Added `Devise::MultiEmail.autosave_emails` option to automatically enable `autosave` on "emails" association

### 2.0.0 - 2017-05-12

* New `Devise::MultiEmail#configure` setup with options for `user` and `emails` associations and `primary_email_record` method names
* Refactor to expose `_multi_email_*` prefixed methods on models
* Changed logic when changing an email address to look up existing email record, otherwise creating a new one, then marking it "primary"
* Changed logic when changing an email address to mark all others as `primary = false`
* Changed logic when changing an email address to `nil` to mark as `primary = false` rather than deleting records

### 1.0.5 - 2016-12-29

* New `.find_by_email` method. Thanks to [mrjlynch](https://github.com/mrjlynch).

### 1.0.4 - 2016-08-13

* Bug fix: Case-insentive configuration of email is ignored (#1). Thanks to [@fonglh](https://github.com/fonglh).

### 1.0.3 - 2016-02-18

* Bug fix: Fix a wrong error message which shows "Email can't be blank" when email does not exist.

### 1.0.2 - 2016-01-12

First stable release.
