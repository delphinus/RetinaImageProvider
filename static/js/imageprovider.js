;'use strict';

(function($){$(document).ready(function(){


var Page = function(){};
Page.prototype = {
    opt: {
        $entry: $('.entry-content')
        ,url: 'http://rip.remora.cx/'
        ,isRetina: window.devicePixelRatio === 2
    }
    ,init: function() {
        var self = this;

        $('img', self.opt.$entry).each(function() {
            var $this = $(this)
                ,imgpath = $this.attr('src')
                    .replace('http://', '')
                    .replace(location.host, '')
                ,targetWidth = $this.parent().width()
                ,targetHeight = $this.parent().height()
                ,reqWidth = targetWidth * (self.opt.isRetina ? 2 : 1)
                ,reqHeight = targetHeight * (self.opt.isRetina ? 2 : 1)
            ;

            if ($this.width() <= self.opt.$entry.width()) {
                return;
            }

            $this.prop({
                src: self.opt.url + '?w=' + reqWidth + '&h=' + reqHeight
                ,height: targetHeight
                ,width: targetWidth
            });
        })

        return self;
    }
};

window.rip = (new Page).init();


});})(jQuery);
