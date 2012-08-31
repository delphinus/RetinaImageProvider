;'use strict';

(function($){$(document).ready(function(){


var Page = function(){};
Page.prototype = {
    opt: {
        $entry: $('.entry-content') // この要素の中の画像を調べる
        ,url: 'http://rip.remora.cx' // 画像供給サーバーの URL
        ,isRetina: window.devicePixelRatio == 2 // 画面は Retina ?
        ,norip: location.search.match(/[?&]norip=(1)/) && RegExp.$1
            // norip パラメータ
    }

    ,init: function() {
        var self = this;

        // norip パラメータが付いてたら何もせずに戻る
        if (self.opt.norip) {
            return self;
        }

        // 画像を検索
        $('img', self.opt.$entry).each(function() {

            var $this = $(this)
                // 親要素の href か、自分自身の src を使う
                ,imgpath = $this.parent().attr('href') || $this.attr('src');

            // もし norip クラスが付いているか、
            if ($this.hasClass('norip')
                    // 画像のパスが見つからないか、
                    || !imgpath || !(
                    // 画像がよそのサーバーにあるのなら帰る
                    imgpath.match('^/') || imgpath.match(location.host))) {
                return;
            }

            // パスからホスト名を取る
            imgpath = imgpath.replace('http://', '').replace(location.host, '');

                // 画像の現在の大きさ
            var width = $this.attr('width')
                ,height = $this.attr('height')
                // 目標の大きさ
                ,targetWidth = $this.parent().width()
                ,targetHeight = Math.floor(targetWidth * height / width)
                // Retina なら 2 倍にする
                ,reqWidth = targetWidth * (self.opt.isRetina ? 2 : 1)
                ,reqHeight = targetHeight * (self.opt.isRetina ? 2 : 1)
            ;

            // 画像を取得して大きさをセットする
            $this.prop({
                src: self.opt.url + imgpath
                    + '?w=' + reqWidth + '&h=' + reqHeight
                ,height: targetHeight
                ,width: targetWidth
            });
        })

        return self;
    }
};

var rip = (new Page).init();
$(window).on('orientationchange', rip.init);


});})(jQuery);
