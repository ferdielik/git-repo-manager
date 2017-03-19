# Git Repo Manager #

Manage git repositories collectively 


**Usage**
<pre>main.rb <properties-file-path> [-dry-run|-d|-r|-h] </pre>

**Sample properties file**

<pre>
root_file: /mnt/c/Users/stuff/Desktop 
repos:
    - ruby:
        - https://github.com/ferdielik/git-repo-manager
    - shell:
        - https://github.com/ferdielik/dotfiles
        - https://github.com/ferdielik/git-helpful-scripts
    - java:
        - https://github.com/ferdielik/design-patterns
        - forks:
            - https://github.com/kdn251/interviews
    - front-end:
        - https://github.com/ferdielik/file-drag-drop-directive
        - https://github.com/ferdielik/js-urlize
</pre>

** Commands **
<pre>
Usage: main.rb <properties> [options]
        --dry-run                    Dry Run
    -d, --download-repositories      Download Repositories
    -r, --reset-repositories         Reset Repositories
    -h, --help                       Displays Help
</pre>

