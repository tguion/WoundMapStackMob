var print = print;
var require = require;
var exports = exports;

var ff = require('ffef/FatFractal'); // FatFractal server-side SDK

exports.preserveReferencesOnServer = function(refNames, throwException) {
    ff.setDebug(false);

    if (! refNames || ! refNames.length) {
        throw {statusCode:400, statusMessage:"refNames parameter was " + JSON.stringify(refNames) + " should be an array value - eg ['refOne','refTwo']"};
    }
    var oldObj = ff.getUpdateEventHandlerData()['old'];
    var newObj = ff.getUpdateEventHandlerData()['new'];

    for (var i = 0; i < refNames.length; i++) {
        var refName = refNames[i];
        var oldReferred = ff.getReferredObject(refName, oldObj);

        if (oldReferred) { // We only need to worry about preserving old references when they already exist
            var newReferred = ff.getReferredObject(refName, newObj);
            if (! newReferred) { // We don't care if the reference is changing, we just need to stop it being set to null
                if (throwException) {
                    throw {statusCode:400, statusMessage:'You may not remove reference ' + refName  + " ( " + oldReferred.ffUrl + " ) from object " + newObj.ffUrl}
                } else {
                    ff.logger.forceWarn("Preserving reference " + refName + " ( " + oldReferred.ffUrl + " ) on object " + newObj.ffUrl);
                    ff.addReferenceToObj(oldReferred.ffUrl, refName, newObj);
                }
            }
        }
    }
};
