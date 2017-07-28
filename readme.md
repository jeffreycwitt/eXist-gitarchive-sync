# eXist-gitarchive-sync

This is a simply utility used for keeping exist collections in sync with
git repository.

This library can be used for listening to a github post commit webhook,
retrieving the archive copy of the most current state of the git master branch,
unpacking the archive contents, and finally replacing the corresponding collection
in exist with the new contents.

# Contributors

* Joe Wicentowski
* Jeffrey C. Witt
