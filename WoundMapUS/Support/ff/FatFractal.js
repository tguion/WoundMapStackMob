var FF_JS_API = FF_JS_API;
var exports = exports;
var print = print;

/** @namespace */

/**
 * @constructor
 */
function ObjectWithMetadata() {
    this.createdBy = null;
    this.createdAt = null;
    this.updatedBy = null;
    this.updatedAt = null;
    this.ffUrl = null;
}

/**
 * @constructor
 */
function ACL() {
    this.readGroups = null;
    this.writeGroups = null;
    this.readUsers = null;
    this.writeUsers = null;
}

/**
 * @constructor
 */
function ExtensionRequestData() {
    this.httpMethod     = null;
    this.httpRequestUri = null;
    this.httpParameters = null;
    this.httpHeaders    = null;
    this.httpCookies    = null;
    this.httpContent    = null;
    this.httpRawContent = null;
    this.ffUser         = null;
}

/**
 * @constructor
 */
function HttpRequestData() {
    this.httpMethod     = null;
    this.httpRequestUri = null;
    this.httpParameters = null;
    this.httpHeaders    = null;
    this.httpCookies    = null;
}

/**
 * @constructor
 */
function GrabBagEventHandlerData() {
    this.parentObj = null;
    this.grabBagName = null;
    this.itemObj = null;
    this.eventType = null;
}

/**
 * @see KeyValueObject.key
 * @see KeyValueObject.value
 * @constructor
 */
function KeyValueObject () {
    /**
     * @type {String}
     */
    this.key = null;
    /**
     * @type {Object}
     */
    this.value = null;
}

/**
 * @see KeyValueCursor.hasNext()
 * @see KeyValueCursor.next()
 * @see KeyValueCursor.close()
 * @constructor
 */
function KeyValueCursor () {
    /**
     * Does the cursor have another object?
     */
    this.hasNext = function() {};
    //noinspection FunctionWithInconsistentReturnsJS
    /**
     * The next key-value-pair. If called when hasNext() is false, this will throw an exception
     * @return KeyValueObject
     */
    this.next = function() {};
    /**
     * Close the cursor and clean up any resources. You should make sure to call this function (typically in a finally{} block)
     */
    this.close = function() {};
    /**
     * Time in millis since cursor was last used
     */
    this.lastUsed = function() {};
    /**
     * Is the cursor closed?
     */
    this.isClosed = function() {};
    /**
     * Description of the cursor
     */
    this.getDescription = function() {};
    //noinspection JSUnusedLocalSymbols
    /**
     * Set the description of the cursor
     * @param {String} description
     */
    this.setDescription = function(/**{String}*/ description) {};
}
/**
 * @constructor
 */
function ExtensionResponse() {
    this.responseCode   = null;
    this.statusMessage  = null;
    this.mimeType       = null;
    this.result         = null;
    this.wrap           = null;
    //noinspection JSUnusedLocalSymbols
    /**
     * @param {String} headerName
     * @param {String} headerValue
     */
    this.addResponseHeader = function(/**{String}*/ headerName, /**{String}*/ headerValue) {};
    //noinspection JSUnusedLocalSymbols
    /**
     * @param {String} cookieName
     * @param {String} cookieValue
     * @param {Number} maxAge in seconds
     * @param {Number} [now] unix time, e.g. if you need it exact for testing */
    this.setCookie = function(cookieName, cookieValue, maxAge, now) {};
}

//
// These next are here just so if you're using an IDE then it doesn't complain about unknown names
//
function NoServerJsApiFunctions() {
    this.getDataService = null;
    this.getThreadLocalObject = null;
    this.httpAppAddress = null;
    this.httpsAppAddress = null;
}

function NoServerAppDataServiceFunctions() {
    //noinspection JSUnusedLocalSymbols
    this.getBlob = function(/**{Object}*/ obj, /**{String}*/ ffUrl) {};
    //noinspection JSUnusedLocalSymbols
    this.saveBlob = function (/**{String}*/ ffUrl, /**{String}*/ blobName, /**{Object}*/ blob, /**{String}*/ mimeType) {};
}

var debug = false;
function setDebug(flag) {
    debug = flag;
}
exports.setDebug = setDebug;

function isDebug() {
    if (debug) return true; else return false;
}
exports.isDebug = isDebug;

/**
 * Allows server-side code to log messages to the application's log with different severities (TRACE, INFO, WARN, ERROR).
 * <br>*** Does not increase your server-side API call count (unless you are LoggingToDatabase) ***
 * @type {{trace: Function, info: Function, warn: Function, error: Function, forceInfo: Function, forceWarn: Function}}
 */
var logger = {
    /** @param {String} msg */
    trace:  function(msg) {if (typeof msg != 'string') throw new Error("Parameter must be a string"); else FF_JS_API.logger.trace(msg);},
    /** @param {String} msg */
    info:   function(msg) {if (typeof msg != 'string') throw new Error("Parameter must be a string"); else FF_JS_API.logger.info(msg);},
    /** @param {String} msg */
    warn:   function(msg) {if (typeof msg != 'string') throw new Error("Parameter must be a string"); else FF_JS_API.logger.warn(msg);},
    /** @param {String} msg */
    error:  function(msg) {if (typeof msg != 'string') throw new Error("Parameter must be a string"); else FF_JS_API.logger.error(msg);},
    /** @param {String} msg */
    forceInfo:   function(msg) {if (typeof msg != 'string') throw new Error("Parameter must be a string"); else FF_JS_API.logger.forceInfo(msg);},
    /** @param {String} msg */
    forceWarn:   function(msg) {if (typeof msg != 'string') throw new Error("Parameter must be a string"); else FF_JS_API.logger.forceWarn(msg);}
};
exports.logger = logger;

/**
 * This function has been deprecated. Please use {@link sendEmail} instead.
 * <br>The sendSMTPMail method allows any Event Handler or Server Extension to send an email programatically.
 * @example ff.sendSMTPEmail("smtp.gmail.com", "465", "true", "465", "YourUserName", "YourPassword",
 "Your email address", "Recipient email address", "Hello, World!", "Hello from FatFractal")
 * @param {string} host        The SMTP host
 * @param {string} port        The SMTP port
 * @param {string} auth        Whether authorization is required (true or false)
 * @param {string} authPort    The SMTP port for authorization
 * @param {string} username    The SMTP username
 * @param {string} password    The SMTP password
 * @param {string} fromAddress The sendMail from email address.
 * @param {string} toAddress   The sendMail to email address.
 * @param {string} subject     The sendMail subject.
 * @param {string} body        The sendMail body.
 * @deprecated
 * @see sendEmail
 */
function sendSMTPEmail(host, port, auth, authPort, username, password, fromAddress, toAddress, subject, body) {
    FF_JS_API.sendSMTPEmail(host, port, auth, authPort, username, password, fromAddress, toAddress, subject, body);
}
//noinspection JSDeprecatedSymbols
exports.sendSMTPEmail = sendSMTPEmail;

/**
 * Improved email-sending function; capable of sending HTML email. Future enhancements to this method will enable
 * sending of attachments (for example, BLOBs from the FatFractal data store).
 * @param {Object} data - an object with the following fields:
 * <br>{String} host        The SMTP host
 * <br>{String} port        The SMTP port
 * <br>{String} auth        Whether authorization is required ("true" or "false")
 * <br>{String} authPort    The SMTP port for authorization
 * <br>{String} username    The SMTP username
 * <br>{String} password    The SMTP password
 * <br>{String} from        The sendMail from email address.
 * <br>{String} fromName    The display name of the sender
 * <br>{String} to          The sendMail to email address.
 * <br>{String} cc          The sendMail cc email address (optional).
 * <br>{String} bcc         The sendMail bcc email address (optional).
 * <br>{String} subject     The sendMail subject.
 * <br>{String} text        Plain text content - MUST be supplied, so that a plain text version of the email can always be sent
 * <br>{String} html        HTML content - optional
 */
function sendEmail(data) {
    var stringifiedData = JSON.stringify(data);
    if (debug) print("sendEmail(data=" + stringifiedData);
    FF_JS_API.sendEmail(JSON.parse(stringifiedData));
}
exports.sendEmail = sendEmail;


/**
 * The sendPushNotifications method allows any server-side code to send Push Notifications programatically.
 * @param {String[]} userGuids An array of userGuid sendPushNotifications will send to.
 * @param {Object} message The message to send in the Push Notifications. Message should be either:
 * <pre>
 *   {ios:{IOS_CONTENT}}
 *     or
 *   {gcm:{GCM_CONTENT}}
 *     or
 *   {ios:{IOS_CONTENT},gcm:{GCM_CONTENT}}
 * </pre>
 * <p>where IOS_CONTENT is content as per "Examples of JSON payloads" in the iOS push notification guide
 * <p>and GCM_CONTENT is content as per the HTTP Message Parameters in the GCM guidelines here http://developer.android.com/google/gcm/server.html
 * <p>Note that in the gcm message, the FatFractal backend takes care of adding in the array of registration_ids
 * @param {Boolean} sendSynchronously Whether to send this message synchronously or queue for delivery asynchronously.
 * WARNING: Synchronous sending is for TESTING purposes only; you should never use synchronous sending in production
 * @example <pre> r = ff.sendPushNotifications (ff.getActiveUser().guid, {
      ios:{
        "aps" : {
          "alert" : {
            "body" : "Bob wants to play poker",
            "action-loc-key" : "PLAY"
          },
          "badge" : 5
        },
        "acme1" : "bar",
        "acme2" : [ "bang",  "whiz" ]
      },
      gcm:{
        "collapse_key": "score_update",
        "time_to_live": 108,
        "delay_while_idle": true,
        "data": {
          "score": "4 x 8",
          "time": "15:16.2342"
        }
      }
    }, false);
 </pre>
 */
function sendPushNotifications(userGuids, message, sendSynchronously) {
    //noinspection JSValidateTypes
    if (! Array.isArray(userGuids))
        throw new Error("sendPushNotifications: userGuid must be a javascript array");
    if (debug) print("sendPushNotifications(userGuids=" + userGuids + ", message=" + message);
    return FF_JS_API.sendPushNotifications(userGuids, message, !!sendSynchronously);
}
exports.sendPushNotifications = sendPushNotifications;

/**
 * @param {String} notificationToken The iOS Notification token - eg &lt;a1a1a1a1 b2b2b2b2 c3c3c3c3 d4d4d4d4 e5e5e5e5 f6f6f6f6 a2a2a2a2 b3b3b3b3&gt;
 * @param {Object} payload. eg:
 * <pre>
    {
        "aps" : {
            "alert" : {
                "body" : "Bob wants to play poker",
                "action-loc-key" : "PLAY"
            },
            "badge" : 5
        },
        "acme1" : "bar",
        "acme2" : [ "bang",  "whiz" ]
    }
 * </pre>
 * @param {String} [certFileName] if not set, will ultimately default to "/resources/ApplePushKeystore.p12"
 * @param {String} [certPassword] - if not set, will ultimately default to the value set in application.ffdl for "ApplePushKeystorePassword"
 * @param {Boolean} [sendSynchronously] - defaults to false. Whether to send this message synchronously or queue for delivery asynchronously.
 * WARNING: Synchronous sending is for TESTING purposes only; you should never use synchronous sending in production
 */
function sendIOSPush (notificationToken, payload, certFileName, certPassword, sendSynchronously) {
    if (! certFileName) certFileName = null;
    if (! certPassword) certPassword = null;
    if (! payload.ios)
        payload = {ios:payload};
    return FF_JS_API.sendIOSPush (notificationToken, payload, certFileName, certPassword, !!sendSynchronously);
}
exports.sendIOSPush = sendIOSPush;

/**
 * A <b>CRUD CREATE</b> method that will attempt to create a new resource on the your apps backend at the
 relativeUrl location. Returns the object, or null in the event of a failure.
 * @example createdMyStuff = ff.createObjAtUrl(myStuff, "/Furniture");
 * @param {Object} obj The instance of any arbitrary class object to be created and persisted on the your apps backend.
 * @param {String} relativeUrl is the url for this resource relative to your applications base HREF.
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {ObjectWithMetadata} the returned object from the your apps backend.
 */
function createObjAtUri(obj, relativeUrl, asUserGuid) {
    if (Array.isArray(obj))
        throw new Error("createObjAtUri requires first parameter to be a single object; an array was supplied");
    if (typeof obj != 'object')
        throw new Error("createObjAtUri requires first parameter to be a JavaScript object");
    if (! asUserGuid)
        asUserGuid = 'system';
    if (! obj.createdBy)
        obj.createdBy = asUserGuid;
    if (debug) print("createObjAtUri(obj=" + JSON.stringify(obj) + ", relativeUrl=" + relativeUrl + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).createObjAtUrl(obj, relativeUrl);
}
exports.createObjAtUri = createObjAtUri;

/**
 * A <b>CRUD READ</b> method that will attempt to retrieve a single resource from this relative URL.
 * @param {String} ffUrl (required) is the url for this resource relative to the #baseUrl property set above.
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @example readMyStuff = ff.getObjFromUri(myStuffUri);
 * @return {ObjectWithMetadata} the returned object from the your apps backend.
 */
function getObjFromUri(ffUrl, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("getObjFromUri(ffUrl=" + ffUrl + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).getObjFromUrl(ffUrl);
}
exports.getObjFromUri = getObjFromUri;

/**
 * A <b>CRUD READ</b> method that will attempt to retrieve 0..N resources from the your apps backend.
 * Returns an <b>Array</b> containing all of the objects of that type at that resource location.
 * @example yourRatings = ff.getArrayFromUri("/WouldYa/(createdBy eq '" + createdBy + "')");
 * @param {String} requestUri (required) is the url for this query. For example @"/ff/resources/MyObjects/(foo eq 'fooValue')"
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {ObjectWithMetadata[]} An array that contains all objects of that type at that resource location.
 */
function getArrayFromUri(requestUri, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("getArrayFromUri(requestUri=" + requestUri + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).getArrayFromUrl(requestUri);
}
exports.getArrayFromUri = getArrayFromUri;

/**
 * A <b>CRUD READ</b> method that will attempt to retrieve 0..N resources from the your apps backend.
 * Returns an <b>Array</b> containing all of the guids for the objects of that type at that resource location.
 * @example totalRatings = ff.getAllGuids("/WouldYa");
 * @param {String} requestUri (required) is the url for this query.
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {String[]} An array that contains all the guids for the objects of that type at that resource location.
 */
function getAllGuids(requestUri, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("getAllGuids(requestUri=" + requestUri + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).getAllGuids(requestUri);
}
exports.getAllGuids = getAllGuids;

/**
 * A <b>CRUD READ</b> method that will attempt to up to a given number of guids from a specified location.
 * @param {String} resourceLocation - uri of the desired resources
 * @param {Number} count - maximum number of guids to return
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {String[]} guids
 */
function getGuids(resourceLocation, count, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("getGuids(resourceLocation=" + resourceLocation + ", count=" + count + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).getGuids(resourceLocation, count);
}
exports.getGuids = getGuids;

/**
 * A <b>CRUD UPDATE</b> method that will attempt to update an existing resource on the your apps backend. The object
 must have previously been retrieved or created via the FF API.
 * @example newTopCeleb = ff.updateObj(currentTopCeleb);
 * @param {Object} obj The instance of any arbitrary class object to be created and persisted on
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 the your apps backend.
 * @return {ObjectWithMetadata} the returned object from the your apps backend.
 */
function updateObj(obj, asUserGuid) {
    if (Array.isArray(obj))
        throw new Error("updateObj requires first parameter to be a single object; an array was supplied");
    if (typeof obj != 'object')
        throw new Error("updateObj requires first parameter to be a JavaScript object");
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("updateObj(obj=" + JSON.stringify(obj) + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).updateObj(obj);
}
exports.updateObj = updateObj;

/**
 * A <b>CRUD DELETE</b> method that will attempt to delete an existing resource from the your apps backend.The object
 must have previously been retrieved or created via the FF API.
 * @example ff.deleteObj(currentTopCeleb);
 * @param {object} obj The instance of any arbitrary class object to be deleted from the your apps backend.
 * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 */
function deleteObj(obj, asUserGuid) {
    if (Array.isArray(obj))
        throw new Error("deleteObj requires first parameter to be a single object; an array was supplied");
    if (typeof obj != 'object')
        throw new Error("deleteObj requires first parameter to be a JavaScript object");
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("deleteObj(obj=" + JSON.stringify(obj) + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).deleteObj(obj);
}
exports.deleteObj = deleteObj;

/**
 * A <b>CRUD DELETE</b> method that will attempt to delete an existing resource from the your apps backend when
 passed in the url location for the object.The object must have previously been retrieved or created via
 the FF API.
 * @param {String} ffUrl The ffUrl of the object to be deleted from the your apps backend.
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @example
 * ff.deleteObjAtUrl("/Celebrity/" + data.pickedGuid);
 */
function deleteObjAtUri (ffUrl, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("deleteObjAtUri(ffUrl=" + ffUrl + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).deleteObjAtUrl(ffUrl);
}
exports.deleteObjAtUri = deleteObjAtUri;

/**
 * Delete all objects which match the query
 * @param {String} query
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {Number} the number of objects which were deleted
 * @example
 * // delete all objects in /Celebrity where firstName == 'Adam'
 * ff.deleteAllForQuery("/Celebrity/(firstName eq 'Adam')");
 * // delete all objects in /Celebrity
 * ff.deleteAllForQuery("/Celebrity");
 * @see getCursorForQuery
 * @see getResultCountForQuery
 */
function deleteAllForQuery (query, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("deleteAllForQuery(query=" + query + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).deleteAllForQuery(query);
}
exports.deleteAllForQuery = deleteAllForQuery;

/**
 * Return a cursor allowing iteration through the set of objects which match the query
 * @param {String} query
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {KeyValueCursor}
 * @example
 * var cursor = ff.getCursorForQuery("/Celebrity/(firstName eq 'Adam')");
 * while (cursor.hasNext()) {
 *   var keyValuePair = cursor.next();
 *   var key = keyValuePair.key;
 *   var obj = keyValuePair.value;
 *   // do stuff
 * }
 * @see KeyValueCursor
 * @see KeyValueObject
 * @see deleteAllForQuery
 * @see getResultCountForQuery
 */
function getCursorForQuery (query, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("getCursorForQuery(query=" + query + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).getCursorForQuery(query);
}
exports.getCursorForQuery = getCursorForQuery;

/**
 * Returns the number of objects which match this query.
 * @param {String} query
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {Number}
 * @example
 * var query = "/Celebrity/(firstName eq 'Adam')";
 * var count = ff.getResultCountForQuery(query);
 * print ("Query " + query + " returns " + count + " objects");
 * @see getCursorForQuery
 * @see deleteAllForQuery
 */
function getResultCountForQuery (query, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("getResultCountForQuery(query=" + query + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).getResultCountForQuery(query);
}
exports.getResultCountForQuery = getResultCountForQuery;

/**
 * Returns a handle to the response object which your extension's code needs to populate in order for data to be returned from your extension.
 * <br>*** Does not increase your server-side API call count ***
 * @return {ExtensionResponse} response object containing the following fields: responseCode, statusMessage, result, mimeType
 * @see getExtensionRequestData
 * @example
 * var r = ff.response();
 * r.responseCode = 200;
 * r.statusMessage = "All is well";
 */
function response() {
    return FF_JS_API.getThreadLocalObject("FF_RESPONSE");
}
exports.response = response;

/**
 * Get request data from within a server extension
 * <br>*** Does not increase your server-side API call count ***
 * @return {ExtensionRequestData} extension request data, with the following fields:
 * <ul>
 * <li>httpMethod: the HTTP method (eg. GET, POST, PUT, DELETE, HEAD)</li>
 * <li>httpRequestUri: the request URI, relative to your application’s base URL</li>
 * <li>httpParameters: A map of the request parameters</li>
 * <li>httpHeaders: A map of the request headers</li>
 * <li>httpCookies: For convenience, a map of the cookies from the Cookie request header</li>
 * <li>httpContent: A map corresponding to the JSON content supplied in the request body, if any</li>
 * <li>ffUser: the guid of the logged-in user.</li>
 * </ul>
 * @see response
 */
function getExtensionRequestData() {
    return FF_JS_API.getThreadLocalObject("FF_EXTENSION_REQUEST_DATA");
}
exports.getExtensionRequestData = getExtensionRequestData;

/**
 * Get HTTP request data (if any) from within any server-side code
 * <br>*** Does not increase your server-side API call count ***
 * @return {HttpRequestData} extension request data, with the following fields:
 * <ul>
 * <li>httpMethod: the HTTP method (eg. GET, POST, PUT, DELETE, HEAD)</li>
 * <li>httpRequestUri: the request URI, relative to your application’s base URL</li>
 * <li>httpParameters: A map of the request parameters</li>
 * <li>httpHeaders: A map of the request headers</li>
 * <li>httpCookies: For convenience, a map of the cookies from the Cookie request header</li>
 * </ul>
 */
function getHttpRequestData() {
    return FF_JS_API.getThreadLocalObject("FF_HTTP_REQUEST_DATA");
}
exports.getHttpRequestData = getHttpRequestData;

/**
 * Get object data from within an event handler. NOTE: When the event is an UPDATE event, this function will return the data for the NEW version of the object.
 * <br>Please use getUpdateEventHandlerData() if you need both the OLD and the NEW versions of the object for UPDATE events.
 * <br>*** Does not increase your server-side API call count ***
 * @return event handler object data and metadata
 * @see getUpdateEventHandlerData
 * @example
 * var data = ff.getEventHandlerData();
 * print("object created at " + data.createdAt + " by " + data.createdBy");
  */
function getEventHandlerData() {
    return FF_JS_API.getThreadLocalObject("FF_EVENT_DATA");
}
exports.getEventHandlerData = getEventHandlerData;

/**
 * Gets the object data for both the OLD and NEW versions of the object, for UPDATE events.
 * <br>*** Does not increase your server-side API call count ***
 * @return an object like this: &#123;old:&#123;<em>&lt;old data&gt;</em>&#125;,new:&#123;<em>&lt;new data&gt;</em>&#125;&#125;
 * @throws {Object} an error if this function is called when the event was not an UPDATE event
 * @see getEventHandlerData
 */
function getUpdateEventHandlerData() {
    return FF_JS_API.getThreadLocalObject("FF_UPDATE_EVENT_DATA");
}
exports.getUpdateEventHandlerData = getUpdateEventHandlerData;

/**
 * Gets the currently 'active' user.
 * <br>*** Does not increase your server-side API call count ***
 * <br>For server extensions, this means the logged-in user (or the 'anonymous' user if the user isn't logged in)
 * <br>For event handlers, this will be the logged-in user,
 * <br>or, if the event was triggered by server-side invocation of a CRUD function,
 * <br>then the active user will be the user identified by the 'asUserGuid' parameter
 * <br>Note: When you invoke CRUD functions server-side, if you omit the 'asUserGuid' parameter then it defaults to the 'system' user.
 * @return {FFUser}
 */
function getActiveUser() {
    return new FFUser(FF_JS_API.getThreadLocalObject("FF_ACTIVE_USER"));
}
exports.getActiveUser = getActiveUser;

/**
 * Get all items from the object's named grab bag
 * @param parentUrl - The ffUrl of the object from whose grab bag we are retrieving
 * @param grabBagName - The grab bag name
 * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @example var grabBagContents = grabBagGetAll(anOrder.ffUrl, "OrderLines");
 * @return {Array} All objects from specified grab bag
 */
function grabBagGetAll(parentUrl, grabBagName, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("grabBagGetAll(parentUrl=" + parentUrl + ", grabBagName=" + grabBagName + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).grabBagGetAll(parentUrl, grabBagName);
}
exports.grabBagGetAll = grabBagGetAll;

/**
 * Get number of items in the object's named grab bag
 * @param {String} parentUrl - The ffUrl of the object from whose grab bag we are retrieving
 * @param {String} grabBagName - The grab bag name
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {Number} The number of objects in the specified grab bag
 */
function grabBagCountObjects(parentUrl, grabBagName, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("grabBagCountObjects(parentUrl=" + parentUrl + ", grabBagName=" + grabBagName + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).grabBagCountObjects(parentUrl, grabBagName);
}
exports.grabBagCountObjects = grabBagCountObjects;

/**
 * Get items, via query, from the object's named grab bag
 * @param parentUrl - The ffUrl of the object from whose grab bag we are retrieving
 * @param grabBagName - The grab bag name
 * @param query - The query string in FatFractal Query Language format
 * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {Array} Objects from specified grab bag matching query
 * @example var results = grabBagGetAllForQuery(anOrder.ffUrl, "OrderLines", "(orderLineValue gt 1000)");
 */
function grabBagGetAllForQuery(parentUrl, grabBagName, query, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("grabBagGetAllForQuery(parentUrl=" + parentUrl + ", grabBagName=" + grabBagName + ", query=" + query + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).grabBagGetAllForQuery(parentUrl, grabBagName, query);
}
exports.grabBagGetAllForQuery = grabBagGetAllForQuery;

/**
 * Add an item to the object's named grab bag.
 * @param {String} itemUrl - The ffUrl of the item which is to be added
 * @param {String} parentUrl - The ffUrl of the object whose grab bag is going to be updated
 * @param {String} grabBagName - The grab bag name
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @example grabBagAdd(anOrderLine.ffUrl, anOrder.ffUrl, "OrderLines");
 */
function grabBagAdd(itemUrl, parentUrl, grabBagName, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("grabBagAdd(itemUrl=" + itemUrl + ", parentUrl=" + parentUrl + ", grabBagName=" + grabBagName + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).grabBagAdd(itemUrl, parentUrl, grabBagName);
}
exports.grabBagAdd = grabBagAdd;

/**
 * Remove an item from the object's named grab bag.
 * <br>For example, grabBagRemove(anOrderLine.ffUrl, anOrder.ffUrl, "OrderLines")
 * @param {String} itemUrl - The ffUrl of the item which is to be removed
 * @param {String} parentUrl - The ffUrl of the object whose grab bag is going to be updated
 * @param {String} grabBagName - The grab bag name
 * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 */
function grabBagRemove(itemUrl, parentUrl, grabBagName, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("grabBagRemove(itemUrl=" + itemUrl + ", parentUrl=" + parentUrl + ", grabBagName=" + grabBagName + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).grabBagRemove(itemUrl, parentUrl, grabBagName);
}
exports.grabBagRemove = grabBagRemove;

/**
 * Sets a specific ACL on an individual object
 * @param {String} ffUrl        - the ffUrl of the object on which we are setting the permissions
 * @param {Array} readUsers     - array of guids (or ffUrls) of the users who will be entitled to read the object
 * @param {Array} readGroups    - array of guids (or ffUrls) of the groups who will be entitled to read the object
 * @param {Array} writeUsers    - array of guids (or ffUrls) of the users who will be entitled to modify the object
 * @param {Array} writeGroups   - array of guids (or ffUrls) of the groups who will be entitled to modify the object
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {void}
 */
function setPermissionOnObject(ffUrl, readUsers, readGroups, writeUsers, writeGroups, asUserGuid) {
    if (typeof ffUrl != 'string')
        throw new Error("setPermissionOnObject requires first parameter to be an ffUrl");

    if (! asUserGuid)
        asUserGuid = 'system';

    if (debug) print(
        "setPermissionOnObject(ffUrl=" + ffUrl + ", readUsers=" + readUsers + ", readGroups=" + readGroups +
        ", writeUsers=" + writeUsers + ", writeGroups=" + writeGroups + ", asUserGuid=" + asUserGuid
    );

    if (! (Array.isArray(readUsers)) && Array.isArray((readGroups) && Array.isArray(writeUsers) && Array.isArray(writeGroups)))
        throw new Error("setPermissionOnObject: readUsers, readGroups, writeUsers and writeGroups must all be javascript arrays");
    return FF_JS_API.getDataService(asUserGuid).setPermissionOnObject(ffUrl,
        readUsers, readGroups,
        writeUsers, writeGroups);
}
exports.setPermissionOnObject = setPermissionOnObject;

/**
 * Set the default permissions for this object. If object has a specific ACL, it is removed so that the defaults
 * apply (PERMIT commands or, if there are no PERMIT commands, the overall system default (public can read, only
 * creator can write)
 * @param {String} ffUrl        - the ffUrl of the object on which we are setting the permissions
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {void}
 */
function setDefaultPermissionOnObject(ffUrl, asUserGuid) {
    if (typeof ffUrl != 'string')
        throw new Error("setDefaultPermissionOnObject requires first parameter to be an ffUrl");

    if (! asUserGuid)
        asUserGuid = 'system';

    if (debug) print("setDefaultPermissionOnObject(ffUrl=" + ffUrl + ", asUserGuid=" + asUserGuid);

    return FF_JS_API.getDataService(asUserGuid).setDefaultPermissionOnObject(ffUrl);
}
exports.setDefaultPermissionOnObject = setDefaultPermissionOnObject;

/**
 * Get the current explicitly-set permissions for this object, if any.
 * @param {String} ffUrl        - the ffUrl of the object
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {ACL}
 */
function getPermission(ffUrl, asUserGuid) {
    if (typeof ffUrl != 'string')
        throw new Error("getPermission requires first parameter to be an ffUrl");

    if (! asUserGuid)
        asUserGuid = 'system';

    if (debug) print("getPermission(ffUrl=" + ffUrl + ", asUserGuid=" + asUserGuid);

    return FF_JS_API.getDataService(asUserGuid).getPermission(ffUrl);
}
exports.getPermission = getPermission;

/**
 * create an FFUser object from a FatFractal object returned from the secure datastore
 * @constructor
 * @param {object} data - the raw data object
 * @return {FFUser} an FFUser object which has the FFUser addGroup and groupWithName functions
 */
function FFUser(data) {
    if (data) {
        if (data.ffUrl) this.ffUrl = data.ffUrl;
        if (data.firstName) this.firstName = data.firstName;
        if (data.lastName) this.lastName = data.lastName;
        if (data.email) this.email = data.email;
        if (data.userName) this.userName = data.userName;
        for (var key in data) { //noinspection JSUnfilteredForInLoop
            this[key] = data[key];
        }
    }
    if (! data) this.createdBy = "system";
    this.clazz = "FFUser";
    /**
     * Add a group to this user's list of groups
     * @param {FFUserGroup} group - the group to be added
     * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
     */
    this.addGroup = function(group, asUserGuid) {
        if (! group)
            throw new Error("FFUser.addGroup - group argument must be supplied");
        if (! group.ffUrl)
            throw new Error("FFUser.addGroup - group argument does not have FF metadata");
        if (! this.ffUrl)
            throw new Error("FFUser.addGroup - this FFUser object does not have FF metadata");
        if (! asUserGuid)
            asUserGuid = 'system';
        grabBagAdd(group.ffUrl, this.ffUrl, "groups", asUserGuid);
    };
    /**
     * Remove a group from this user's list of groups
     * @param {FFUserGroup} group - the group to be removed
     * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
     */
    this.removeGroup = function(group, asUserGuid) {
        if (! group)
            throw new Error("FFUser.removeGroup - group argument must be supplied");
        if (! group.ffUrl)
            throw new Error("FFUser.removeGroup - group argument does not have FF metadata");
        if (! this.ffUrl)
            throw new Error("FFUser.removeGroup - this FFUser object does not have FF metadata");
        if (! asUserGuid)
            asUserGuid = 'system';
        grabBagRemove(group.ffUrl, this.ffUrl, "groups", asUserGuid);
    };
    /**
     * Get the group called groupName from this user's list of groups
     * @param {string} groupName - the name of the group to be retrieved
     * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
     * @return {FFUserGroup} the group with this name, or null if no group with this name exists
     */
    this.groupWithName = function(groupName, asUserGuid) {
        if (! asUserGuid)
            asUserGuid = 'system';
        var matches = getArrayFromUri(this.ffUrl + "/groups/(groupName eq '" + groupName + "')", asUserGuid);
        if (matches.length != 0)
            return new FFUserGroup(matches[0]);
        else
            return null;
    };
    return this;
}
exports.FFUser = FFUser;

/**
 * create an FFUserGroup object from a FatFractal object returned from the secure datastore
 * @constructor
 * @param {ObjectWithMetadata} [data] - the raw data object
 * @return {FFUserGroup} - an FFUserGroup object which has the FFUserGroup addUser and removeUser functions
 */
function FFUserGroup(data) {
    if (data) {
        if (data.ffUrl) this.ffUrl = data.ffUrl;
        if (data['groupName']) this.groupName = data['groupName'];
        for (var key in data) { //noinspection JSUnfilteredForInLoop
            this[key] = data[key];
        }
    }
    if (! data) this.createdBy = "system";
    this.clazz = "FFUserGroup";
    /**
     * Add a user to this group
     * @param {FFUser} user - the user to be added
     * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
     */
    this.addUser = function(user, asUserGuid) {
        if (! user)
            throw new Error("FFUserGroup.addUser - user argument must be supplied");
        if (! user.ffUrl)
            throw new Error("FFUserGroup.addUser - user argument does not have FF metadata");
        if (! this.ffUrl)
            throw new Error("FFUserGroup.addUser - this FFUserGroup object does not have FF metadata");
        if (! asUserGuid)
            asUserGuid = 'system';
        grabBagAdd(user.ffUrl, this.ffUrl, "users", asUserGuid)
    };
    /**
     * Remove a user from this group
     * @param {FFUser} user - the user to be removed
     * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
     */
    this.removeUser = function(user, asUserGuid) {
        if (! user)
            throw new Error("FFUserGroup.removeUser - user argument must be supplied");
        if (! user.ffUrl)
            throw new Error("FFUserGroup.removeUser - user argument does not have FF metadata");
        if (! this.ffUrl)
            throw new Error("FFUserGroup.removeUser - this FFUserGroup object does not have FF metadata");
        if (! asUserGuid)
            asUserGuid = 'system';
        grabBagRemove(user.ffUrl, this.ffUrl, "users", asUserGuid)
    };
    return this;
}
exports.FFUserGroup = FFUserGroup;

/**
 * create an empty FFMetaData object or populate with data from a FatFractal object returned from the secure datastore
 * @constructor
 * @param {object} obj - the raw obj object
 * @return {FFMetaData} an FFMetaData object
 */
function FFMetaData(obj) {
    this.clazz         = null;
    this.ffUrl         = null;
    this.guid          = null;
    this.ffRL          = null;
    this.objVersion    = null;
    this.createdBy     = null;
    this.createdAt     = null;
    this.updatedBy     = null;
    this.updatedAt     = null;
    this.ffRefs        = [];
    this.ffUserCanEdit = false;
    if(obj) {
        this.clazz         = obj.clazz;
        this.ffUrl         = obj.ffUrl;
        this.guid          = obj.guid;
        this.ffRL          = obj.ffRL;
        this.objVersion    = obj.objVersion;
        this.createdBy     = obj.createdBy;
        this.createdAt     = obj.createdAt;
        this.updatedBy     = obj.updatedBy;
        this.updatedAt     = obj.updatedAt;
        this.ffRefs        = obj.ffRefs;
        this.ffUserCanEdit = obj.ffUserCanEdit;
    }
    return this;
}
exports.FFMetaData = FFMetaData;

/**
 * Get the HTTP address of the application
 * <br>*** Does not increase your server-side API call count ***
 * @return {string} HTTP address
 */
function getHttpAppAddress() {
    return FF_JS_API.httpAppAddress;
}
exports.getHttpAppAddress = getHttpAppAddress;

/**
 * Get the HTTPS address of the application
 * <br>*** Does not increase your server-side API call count ***
 * @return {string} HTTPS address
 */
function getHttpsAppAddress() {
    return FF_JS_API.httpsAppAddress;
}
exports.getHttpsAppAddress = getHttpsAppAddress;

/**
 * Utility method to get an FFUser from the datastore.
 * @param {String} userGuid - the guid of the FFUser we want to retrieve
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {FFUser} the user
 */
function getUser(userGuid, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    var data = getObjFromUri("/FFUser/" + userGuid, asUserGuid);
    if (data == null) return null; else return new FFUser(data);
}
exports.getUser = getUser;

/**
 * Utility method to get an FFUserGroup from the datastore.
 * @param {string} groupGuid - the guid of the FFUserGroup we want to retrieve
 * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {FFUserGroup} the group
 */
function getGroup(groupGuid, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    var data = getObjFromUri("/FFUserGroup/" + groupGuid, asUserGuid);
    if (data == null) return null; else return new FFUserGroup(data);
}
exports.getGroup = getGroup;

/**
 * Utility method to get the ffUrl of a referred object
 * @param obj
 * @param refName
 * @returns {*}
 */
function getRefUrl(obj, refName) {
    if (! obj || ! obj.ffRefs || ! obj.ffRefs[0] || ! refName)
        return null;
    for (var i = 0; i < obj.ffRefs.length; i++) {
        if (obj.ffRefs[i].name === refName) {
            return obj.ffRefs[i].url;
        }
    }
    return null;
}
exports.getRefUrl = getRefUrl;

/**
 * Utility method to see if a reference has changed between two versions of the same object - very useful in UPDATE event handlers
 * @param oldObj
 * @param newObj
 * @param refName
 * @returns {boolean}
 * @example
 // Let's say you have an event handler for UPDATE on an object where you want to detect if the blob has changed
 exports.blobUpdateTestEventHandler = function() {
     var data = ff.getUpdateEventHandlerData();
     var oldObj = data['old'];
     var newObj = data['new'];

     var refName = 'testBlob';
     if (refChanged(oldObj, newObj, refName)) {
        // Do something useful
     }
 };

 */
function refChanged(oldObj, newObj, refName) {
    var oldRefUrl = getRefUrl(oldObj, refName);
    var newRefUrl = getRefUrl(newObj, refName);

    print ("refChanged determined that oldRefUrl is [" + oldRefUrl + "] and newRefUrl is [" + newRefUrl + "]");

    return (! (oldRefUrl === newRefUrl));
}
exports.refChanged = refChanged;

/**
 * Explicitly add a FatFractal 'reference to another object' to this object. For example, addReferenceToObj(user.ffUrl, "ffUser", profile)
 * will add a reference to the 'user' object to the 'profile' object.
 * <br>*** Does not increase your server-side API call count ***
 * <br><b>NB: </b>This function does NOT persist this object. You will need to call updateObj
 * @param {String} ffUrl the referenced object's ffUrl
 * @param {String} refName the name we are giving to this reference relationship
 * @param {Object} obj the object to which we are adding the reference
 */
function addReferenceToObj(ffUrl, refName, obj) {
    if (ffUrl == null || refName == null || obj == null)
        throw new Error ("addReferenceToObj: ffUrl, refName and obj must all be supplied");

    if (typeof ffUrl != 'string')
        throw new Error("addReferenceToObj: requires first parameter to be an ffUrl");

    if (! ffUrl.match(/^\/ff\/resources\/[-A-Za-z0-9_@]+\/[\-A-Za-z0-9_@]+/))
        throw new Error("addReferenceToObj: invalid ffUrl [" + ffUrl + "]: should be of form /ff/resources/<collection>/<guid>");

    if (! obj.ffRefs)
        obj.ffRefs = [];

    for (var i=0; i < obj.ffRefs.length; i++) {
        if (obj.ffRefs[i].name == refName)
            throw new Error("addReferenceToObj: object already has reference with name " + refName);
    }

    obj.ffRefs.push({name:refName,type:"FFO",url:ffUrl});
}
exports.addReferenceToObj = addReferenceToObj;

/**
 * Remove the FatFractal 'reference to another object' with the name 'refName' from this object.
 * <br>*** Does not increase your server-side API call count ***
 * <br><b>NB: </b>This function does NOT persist this object. You will need to call updateObj
 * @param {String} refName the name of the reference relationship
 * @param {Object} obj the object from which to remove the reference
 */
function removeReferenceFromObj(refName, obj) {
    if (refName == null || obj == null)
        throw new Error ("removeReferenceFromObj: refName and obj must all be supplied");

    if (! obj.ffRefs)
        return;

    var oldRefs = obj.ffRefs;
    obj.ffRefs = [];

    for (var i = 0; i < oldRefs.length; i++) {
        if (oldRefs[i].name != refName)
            obj.ffRefs.push(oldRefs[i]);
    }
}
exports.removeReferenceFromObj = removeReferenceFromObj;

/**
 * Get a referred object
 * @param {String} refName the name of the reference relationship
 * @param {Object} obj the referring object
 * @param {String} asUserGuid Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 */
function getReferredObject (refName, obj, asUserGuid) {
    if (refName == null || obj == null)
        throw new Error ("getReferredObject: refName and obj must all be supplied");

    if (debug) print("getReferredObject(refName=" + refName + ", obj=" + JSON.stringify(obj) + ", asUserGuid=" + asUserGuid);

    if (! obj.ffRefs)
        return null;
    
    for (var i = 0; i < obj.ffRefs.length; i++) {
        if (obj.ffRefs[i].name == refName) {
            return getObjFromUri(obj.ffRefs[i].url, asUserGuid);
        }
    }
    return null;
}
exports.getReferredObject = getReferredObject;

/**
 * Get a BLOB member for an object.
 * @param {String} blobName the member name of the BLOB
 * @param {Object} obj the object
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {Binary} the BLOB
 * @example
 * var userProfile = ...    // object with blob member "imageData"
 * getBlob("imageData", userProfile);
 */
function getBlob(blobName, obj, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';

    if (! blobName || ! obj)
        throw new Error ("getBlob: blobName and obj must be supplied");

    if (debug) print("getBlob(blobName=" + blobName + ", obj=" + JSON.stringify(obj) + ", asUserGuid=" + asUserGuid);

    if (! obj.ffRefs)
        return null;

    for (var i = 0; i < obj.ffRefs.length; i++) {
        if (obj.ffRefs[i].name == blobName) {
            return FF_JS_API.getDataService(asUserGuid).getBlob(obj, obj.ffRefs[i].url);
        }
    }
    return null;
}
exports.getBlob = getBlob;

/**
 * Save a BLOB.
 * @param {Object} obj the object whose member this blob is
 * @param {String} blobName the member name of the BLOB
 * @param {Binary} blob the binary data itself
 * @param {String} mimeType the mime type of the BLOB
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @return {ObjectWithMetadata} the updated object (version, updatedAt, ffRefs and possibly updatedBy will all have changed)
 * @example
 * var blobPng = ...
 * saveBlob(userProfile, "imageData", blobPng, "image/png");
 */
function saveBlob(obj, blobName, blob, mimeType, asUserGuid) {
    if (! blobName || ! obj || ! blob || ! mimeType)
        throw new Error ("saveBlob: obj, blobName, blob and mimeType params must be supplied");

    if (! asUserGuid)
        asUserGuid = 'system';

    if (debug) print("saveBlob(obj=" + JSON.stringify(obj) + ", blobName=" + blobName + ", blob=" + blob + ", mimeType=" + mimeType + ", asUserGuid=" + asUserGuid);

    return FF_JS_API.getDataService(asUserGuid).saveBlob(obj.ffUrl, blobName, blob, mimeType);
}
exports.saveBlob = saveBlob;

/**
 * Force a password change for this user.
 * @param {String} userGuid - the guid of the user whose password is being changed
 * @param {String} password - the new password
 */
function resetPassword(userGuid, password) {
    if (debug) print ("resetPassword(userGuid=" + userGuid + ", password=##########");
    FF_JS_API.resetPassword(userGuid, password);
}
exports.resetPassword = resetPassword;

/**
 * Register a new user. Note that this first version only registers LOCAL users - i.e. not Twitter, Facebook etc
 * <br>The next major release will really open up the registration / authentication mechanisms giving developers much more control
 * @param {Object} user An object with (at least) the following keys:
 * <br>userName, firstName, lastName, email
 * @param {String} password - the initial password
 * @param {Boolean} active - defines whether or not the user will be 'active' i.e. able to do anything other than login and retrieve data
 * @param {Boolean} fireEvents - defines whether or not to fire /FFUser Create events (and thus have any defined event handlers execute)
 * @return {FFUser} the newly created user
 */
function registerUser(user, password, active, fireEvents) {
    if (debug) print("registerUser(user=" + JSON.stringify(user) + ", password=#######, active=" + active + ", fireEvents=" + fireEvents);
    return new FFUser(FF_JS_API.registerUser(user, password, active, fireEvents));
}
exports.registerUser = registerUser;

/**
 * Gets the same (almost) app metadata as that which is returned when you make a call to /ff/metadata from the web.
 * <br>*** Does not increase your server-side API call count ***
 * <br>NB: Unlike the call from the web, this server-side function will return all PRIVATE SETtings as well as the public ones</br>
 * @return {*}
 */
function getAppMetaData() {
    return JSON.parse(FF_JS_API.getAppMetaData());
}
exports.getAppMetaData = getAppMetaData;

/**
 * Execute some FFDL. Can supply multiple commands if they are separated by newlines. Will throw an exception if something goes wrong (eg incorrect syntax).
 * <br>*** Does not increase your server-side API call count ***
 * @param {String} ffdl The FFDL to execute
 * @return [{String}] any errors encountered
 */
function executeFFDL(ffdl) {
    return FF_JS_API.executeFFDL(ffdl);
}
exports.executeFFDL = executeFFDL;

/**
 * Get a SETting (whether defaulted, or as set in application.ffdl)
 * <br>*** Does not increase your server-side API call count ***
 * @param paramName
 * @return {String} - null if no value has been set
 */
function getFfdlSetting(paramName) {
    if (typeof paramName != 'string')
        throw new Error("getFfdlSetting requires a string parameter");

    return FF_JS_API.getFfdlSetting(paramName);
}
exports.getFfdlSetting = getFfdlSetting;

/**
 * <br>*** Does not increase your server-side API call count ***
 * @param {Array} objs
 * @param {String} queryFrag
 */
function filterObjectsWithFFRQL(objs, queryFrag) {
    if (! Array.isArray(objs))
        throw new Error("filterObjectsWithFFRQL: objs must be a javascript array");

    if (typeof queryFrag != 'string')
        throw new Error("getFfdlSetting requires a string parameter");

    return FF_JS_API.getDataService('system').filterObjectsWithFFRQL(objs, queryFrag);
}
exports.filterObjectsWithFFRQL = filterObjectsWithFFRQL;

/**
 * Available from release 1.3.0
 * @param b
 */
function setBypassCache(b) {
    if (debug) print("bypassCache set to " + !!b);
    //noinspection JSUnresolvedFunction
    FF_JS_API.setBypassCache(!!b);
}

/**
 * Available from release 1.3.0
 * <br>For paid subscriptions, there are always at least two instances of your app's backend running.
 * <br>NoServer instances cache some recently-used data. In normal circumstances the cache in one instance
 * of your app will be invalidated by changes in another instance, within 1-5 milliseconds. However
 * sometimes you just need to be CERTAIN that you are hitting the data store directly.
 * <br>For example if a user of your app has just made an in-app purchase, and immediately makes a
 * subsequent request to retrieve data which should only be accessible following that purchase,
 * then you will want to be absolutely sure that the second request (which may go to a different instance
 * of your app's backend) will accurately reflect the data.
 * @param {Function} f
 * @returns {Function}
 * @example
 * var obj = ff.bypassCache(ff.getObjFromUri) ("/FFUser/anonymous");
 */
function bypassCache(f) {
    return function (arguments) {
        try {
            setBypassCache(true);
            return f(arguments)
        } finally {
            setBypassCache(false);
        }
    };
}
exports.bypassCache = bypassCache;

/**
 * Execute some SQL, if your subscription includes the "relational collections" feature (currently in alpha trials)
 * <br>If your subscription does not support relational collections, then an exception will be thrown
 * @param {String} sql
 * @return {Object}
 */
function executeSQL(sql) {
    return FF_JS_API.executeSQL(sql);
}
exports.executeSQL = executeSQL;

/**
 * A server-side function allowing the equivalent of the client-side queries using depthRef and depthGb parameters
 * - see http://fatfractal.com/docs/queries/#retrieving-related-objects-inline
 * @param {Array} base - the list of objects for which you want to run a depth query
 * @param depthRef - see http://fatfractal.com/docs/queries/#retrieving-related-objects-inline
 * @param depthGb - see http://fatfractal.com/docs/queries/#retrieving-related-objects-inline
 * @param {String} [asUserGuid] Defaults to 'system'. The operation is executed as if it were this user, so all security access controls will be in effect.
 * @returns {Object} with two keys:
 * 'references' - being an array of all referred objects
 * 'grabBagItems' - being a map (keyed by ffUrl) of maps (keyed by grab-bag name) of arrays of ffUrls
 *
 * @example
 * // For example in a server extension
 * var guidParam = ff.getExtensionRequestData().httpParameters['guid'];
 * var objs = ff.getArrayFromUri("/Collection/" + guidParam);
 * var depthResponse = ff.executeDepthQuery(objs, 2, 2, 'system');
 * ff.response().wrap = false; // Must have this - otherwise result will look like {statusMessage:null,result:{statusMessage:'Doing...',result:...,references:...,grabBagItems:...}}
 * ff.response().result = {
 *     statusMessage:'Doing depth queries on the server side',
 *     result:objs,
 *     references:depthResponse.references,
 *     grabBagItems:depthResponse.grabBagItems
 * };
 */
function executeDepthQuery(base, depthRef, depthGb, asUserGuid) {
    if (! asUserGuid)
        asUserGuid = 'system';
    if (debug) print("executeDepthQuery(base=[array of " + base.length + " objects], depthRef=" +depthRef + ", depthGb=" + depthGb + ", asUserGuid=" + asUserGuid);
    return FF_JS_API.getDataService(asUserGuid).executeDepthQuery(base, depthRef, depthGb);
}
exports.executeDepthQuery = executeDepthQuery;

function xml2json(xml) {
    if (typeof xml != 'string') {
        throw new Error("ERROR: xml2json: 'xml' parameter must be a string");
    } else {
        return FF_JS_API.xml2json(xml);
    }
}
exports.xml2json = xml2json;

// Backwards compatibility
exports.createObjAtUrl = createObjAtUri;
exports.getObjFromUrl = getObjFromUri;
exports.getArrayFromUrl = getArrayFromUri;
exports.deleteObjAtUrl = deleteObjAtUri;

