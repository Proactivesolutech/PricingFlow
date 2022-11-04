function IncludeRandomVerNo() {
    //var str = '?v=' + Math.random().toString().replace('0.', '')
    var str = '?v=1.0.2.4'
    return str
}
function IncludeCSS(file) {
    var link = document.createElement( "link" );
    link.href = file + IncludeRandomVerNo();
    link.type = "text/css";
    link.rel = "stylesheet";
    link.media = "screen,print";
    document.getElementsByTagName( "head" )[0].appendChild( link );
}
function IncludeJS(file) {
    var script = document.createElement("script");
    script.src = file + IncludeRandomVerNo();
    script.type = "text/javascript";
    script.async = false;
    document.getElementsByTagName("head")[0].appendChild(script);
}