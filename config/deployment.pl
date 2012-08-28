use Path::Class;
my $basedir = file(__FILE__)->parent->parent;
my $dotcloud = dir('/home/dotcloud');
my $dbpath = -d $dotcloud ? $dotcloud->file('deployment.db')
    : $basedir->file('db', 'deployment.db');
my $imgpath = dir('/Library/WebServer/Documents/blog/assets_c');
-d $imgpath or die;
+{
    DBI => [
        "dbi:SQLite:dbname=$dbpath",
        '',
        '',
        +{
            sqlite_unicode => 1,
        }
    ],
    IMGPATH => $imgpath->stringify,
};
