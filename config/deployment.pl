use Path::Class;
my $basedir = file(__FILE__)->parent->parent;
my $dotcloud = dir('/home/dotcloud');
my $dbpath = -d $dotcloud ? $dotcloud->file('deployment.db')
    : $basedir->file('db', 'deployment.db');
my $imgpath = $basedir->subdir('img');
-d $imgpath or $imgpath->mkpath;
+{
    DBI => [
        "dbi:SQLite:dbname=$dbpath",
        '',
        '',
        +{
            #sqlite_unicode => 1,
        }
    ],
    IMGPATH => $imgpath->stringify,
    validator => +{
        messages => $basedir->file('config', 'messages.yml')->stringify,
        profiles => $basedir->file('config', 'profiles.yml')->stringify,
        message_decode_from => 'UTF-8',
    },
};
