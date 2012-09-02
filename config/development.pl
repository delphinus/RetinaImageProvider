use Path::Class;
my $basedir = file(__FILE__)->parent->parent;
my $dotcloud = dir('/home/dotcloud');
my $dbpath = -d $dotcloud ? $dotcloud->file('development.db')
    : $basedir->file('db', 'development.db');
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
    LOG => $basedir->file('logs/app.log'),
    IMGPATH => $imgpath->stringify,
    validator => +{
        messages => $basedir->file('config', 'messages.yml')->stringify,
        message_decode_from => 'UTF-8',
    },
};
