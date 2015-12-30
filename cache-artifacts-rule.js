// http://mirror.centos.org/centos/7.1.1503/os/x86_64/Packages/ImageMagick-devel-6.7.8.9-10.el7.i686.rpm
// replace all the images with local one
var fs = require("fs");
var redis = require("redis");
var client = redis.createClient();

// client.set("foo_rand000000000000", "OK");
// client.end();

// client.get("foo_rand000000000000", function (err, reply) {
//     // This won't be called anymore, since flush has not been set to true!
//     console.log(err);
// });

var LOCAL_IMAGE = "/Users/path/to/image.png";
var isRpm = false;

module.exports = {

    summary:function(){
        return "replace all the images with local one";
    },

    //mark if use local response
    shouldUseLocalResponse : function(req,reqBody){
        if(/\.(rpm)$/.test(req.url)){
            isRpm = true;
            client.set(, "OK");
            req.replaceLocalFile = true;
            return true;
        }else{
            return false;
        }
    },

    dealLocalResponse : function(req,reqBody,callback){
        if(req.replaceLocalFile && isRpm){
            callback(200, {"content-type":"application/x-rpm"}, fs.readFileSync(LOCAL_IMAGE) );
        }
    }
};
