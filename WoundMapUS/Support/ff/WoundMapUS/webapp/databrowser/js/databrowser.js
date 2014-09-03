var ff = new FatFractal();
ff.setBaseUrl(ff.getBaseUrl());
ff.setDebug(false);
ff.setAutoLoadBlobs(false);

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return !(a.indexOf(i) > -1);});
};

function getParameterByName(name)
{
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.search);
    if (results == null) {
        return "";
    } else {
        return decodeURIComponent(results[1].replace(/\+/g, " "));
    }
}

ko.bindingHandlers.ffdb_displayResults = {
    update: function(element, valueAccessor) {
        $(element).empty(); // empty the div

        var value = valueAccessor();
        var valueUnwrapped = ko.utils.unwrapObservable(value);

        var theTables = createSummaryTables(valueUnwrapped);
        addTablesToElement(theTables, element);
    }
};

ko.bindingHandlers.datepicker = {
    init: function(element, valueAccessor) {
        $(element).addClass('input-append');
        var input = $('<input class="datetime-text-input" data-format="yyyy-MM-dd hh:mm:ss.ms Z" type="text" placeholder="yyyy-MM-dd hh:mm:ss.ms Z">');
        $(element).append(input);
        $(element).append('<span class="add-on"><i data-time-icon="icon-time" data-date-icon="icon-calendar"></i></span>');
        $(element).datetimepicker(
            {
                language: 'en',
                pick12HourFormat: true
            });

        var value = valueAccessor();
        var valueUnwrapped = ko.utils.unwrapObservable(valueAccessor());
        var picker = $(element).data('datetimepicker');
        picker.setDate(valueUnwrapped);
        $(element).on('changeDate', function(event) {
            value(event.date);
        });
    },
    update: function(element, valueAccessor) {

    }
};

ko.bindingHandlers.ffdb_blob = {
    init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        // this stuff is dubious
        var newObj = bindingContext.$root.detailObject().newObj;
        var canEdit = bindingContext.$root.detailObject().canEdit;
        var obj = bindingContext.$root.detailObject().obj;

        var field = valueAccessor().fieldName;
        var value = bindingContext.$root.detailObject().fieldVals[field];

        var fileElement = $('<input type="file">');
        fileElement.on('change', function(event) {
            var files = fileElement[0].files;
            if (files.length > 0) {
                value(files[0]);
            } else {
                value(null);
            }
        });
        if (newObj) {
            $(element).append(fileElement);
        } else {
            var url = ff.getBaseUrl() + obj.ffUrl + "/" + field;

            var showElement = $('<div></div>');
            showElement.append('<a href="' + url + '" target="_blank">Show</a>');
            $(element).append(showElement);

            if (canEdit) {
                var editLink = $('<a href="#">Edit</a>');
                showElement.append(' | ', editLink);

                var editElement = $('<div></div>');
                editElement.append(fileElement);
                var cancelLink = $('<a href="#">Cancel</a>');
                editElement.append(cancelLink);
                editElement.hide();

                // set up click event handlers
                editLink.click((function(showEl, editEl) {
                    return function() {
                        showEl.hide();
                        editEl.show();
                    }
                })(showElement, editElement));
                cancelLink.click((function(showEl, editEl, fileEl) {
                    return function() {
                        showEl.show();
                        editEl.hide();

                        // need the following to reset file chooser, ick
                        // see http://stackoverflow.com/questions/1043957/clearing-input-type-file-using-jquery
                        fileEl.wrap('<form>').closest('form').get(0).reset();
                        fileEl.unwrap();

                        fileEl.trigger('change');
                    }
                })(showElement, editElement, fileElement));

                $(element).append(editElement);
            }
        }
    }
};

ko.bindingHandlers.popover = {
    init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var content = valueAccessor();
        var popover = {
            html: true,
            content: content
        };
        $(element).popover(popover);
    }
};

ko.bindingHandlers.selectReference = {
    init: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var value = valueAccessor();

        var allBindings = allBindingsAccessor();
        var objWrapper = allBindings.selectReferenceObjWrapper;
        var field = allBindings.selectReferenceFieldObj;

        var obj = objWrapper.obj;
        var fieldName = field.fieldName;

        var objMenu = $('<input type="hidden">');

        var permittedCollections;
        if (field.collectionName) {
            permittedCollections = [field.collectionName];
        } else {
            // all collections
            permittedCollections = bindingContext.$root.mdCollections().map(function(el) { return el.collectionName; });
        }

        // attach handler
        objMenu.on('change', function(event) {
            value(objMenu.val());
        });

        $(element).append(objMenu);

        // set up select2 menu
        // TODO: exclude objects already in e.g. grabbag
        formattedObjectsForCollections(permittedCollections, null, function(resultArr) {
            objMenu.select2({
                width: 300,
                placeholder: "null",
                allowClear: true,
                //multiple: true,
                initSelection: function(element, callback) {
                    var done = false;
                    for (var i = 0; !done && i < resultArr.length; i++) {
                        var group = resultArr[i].children;
                        for (var j = 0; !done && j < group.length; j++) {
                            var item = group[j];
                            if (item.id == element.val()) {
                                callback(item);
                                done = true;
                            }
                        }
                    }
                },
                query: function(query) {
                    var queryTerms = query.term.split(/\W+/);
                    var results = searchFormattedObjects(resultArr, queryTerms);
                    query.callback({ results: results });
                },
                formatResult: function(object, container, query) {
                    var result = object.text;
                    if (object.obj) {
                        // test because this might be a group (collection) item
                        container.prop('title', getAltToolTip(object.obj));
                        result = getHtmlJson(object.obj, object.matchedFields);
                    }
                    return result;
                },
                formatSelection: function(object, container) {
                    var html = "<span title='" + getAltToolTip(object.obj) + "'>" + object.text + "</span>";
                    return html;
                },
                escapeMarkup: function(m) { return m; }
            });

            if (obj[fieldName] && obj[fieldName].ffUrl) {
                // TODO: use value accessor??
                objMenu.select2('val', obj[fieldName].ffUrl);
            }
        });
    },
    update: function(element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) {
        var value = valueAccessor();
        var objMenu = $(element).find('input');
        objMenu.select2('val', value());
    }
};

ko.bindingHandlers.ffdb_newObjectMenu = {
    update: function(element, valueAccessor) {
        $(element).empty(); // empty the div

        var value = valueAccessor();
        var collection = ko.utils.unwrapObservable(value);

        // build menu
        var menu = $('<ul class="dropdown-menu pull-right"></ul>');
        var objTypeNames = collection.objectTypeNames;

        // build objTypes array
        var objTypes = [];
        var mdObjTypes = ffdb_mainViewModel.mdObjectTypes();
        if (objTypeNames[0] === '*') {
            // all objects
            for (var i = 0; i < mdObjTypes.length; i++) {
                if (mdObjTypes[i].objectTypeName === '*') continue;
                objTypes.push(mdObjTypes[i]);
            }
        } else {
            for (i = 0; i < mdObjTypes.length; i++) {
                if ($.inArray(mdObjTypes[i].objectTypeName, objTypeNames) != -1) {
                    objTypes.push(mdObjTypes[i]);
                }
            }
        }

        for (i = 0; i < objTypes.length; i++) {
            var item = $('<li></li>');
            var typeName = objTypes[i].objectTypeName;
            var shortTypeName = shorten(typeName);
            var itemLink = $('<a href="#">' + shortTypeName + '</a>');
            $(itemLink).click((function(typeName) {
                return function() {
                    ffdb_mainViewModel.newObject(typeName, collection.collectionName);
                }
            })(typeName));  // this is ridiculous
            $(item).append(itemLink);
            //if (shortTypeName !== typeName) $(item).tooltip({ title: typeName });
            if (shortTypeName !== typeName) $(item).prop('title', typeName);
            $(menu).append(item);
        }

        var btnGroup = $('<div class="btn-group"></div>');
        var addObjectTitle = "Create object in " + collection.collectionName + " collection";
        $(btnGroup).append('<button class="btn dropdown-toggle" title="' + addObjectTitle + '" data-toggle="dropdown"><i class="icon-plus"></i></button>');
        $(btnGroup).append(menu);
        $(element).append(btnGroup);
    }
};

function insertCollectionObjsIntoMenu(collections, menu, successCallback) {
    // TODO: add error callback?
    if (collections.length > 0) {
        var collection = collections[0];
        var restCollections = collections.splice(1);

//        menu.append('<option disabled>' + collection + '</option>');
        var optGroup = $('<optgroup></optgroup>');
        optGroup.attr('label', collection);
        ff.getArrayFromUri(collection, function(result) {
            for (var j = 0; j < result.length; j++) {
                var menuItem = $('<option>' + result[j].guid + '</option>');
                menuItem.prop('title', getAltToolTip(result[j]));
                menuItem.val(result[j].ffUrl);
                optGroup.append(menuItem);
            }
            menu.append(optGroup);
            insertCollectionObjsIntoMenu(restCollections, menu, successCallback);
        }, function(errCode, errMsg) {
            var msg = "Error " + errCode + ": " + errMsg;
            toastError(msg);
            console.error(msg);
        });
    } else if (successCallback) {
        successCallback();
    }
}

function formattedObjectsForCollections(collections, resultArr, successCallback) {
    if (collections.length > 0) {
        if (!resultArr) resultArr = [];

        var collection = collections[0];
        var restCollections = collections.splice(1);

        ff.getArrayFromUri(collection, function(result) {
            var group = [];
            for (var j = 0; j < result.length; j++) {
                var guid = result[j].guid;
                var ffUrl = result[j].ffUrl;
                group.push({
                    text: guid,
                    id: ffUrl,
                    obj: result[j],
                    matchedFields: []
                });
            }
            if (group.length > 0) resultArr.push({ text: collection, children: group });
            formattedObjectsForCollections(restCollections, resultArr, successCallback);
        }, function(errCode, errMsg) {
            var msg = "Error " + errCode + ": " + errMsg;
            toastError(msg);
            console.error(msg);
        });
    } else if (successCallback) {
        successCallback(resultArr);
    }
}

function searchFormattedObjects(formattedObjects, queryTerms) {
    var results = [];

    for (var i = 0; i < formattedObjects.length; i++) {
        var group = formattedObjects[i];
        var groupResultArr = [];

        for (var j = 0; j < group.children.length; j++) {
            var item = group.children[j];
            item.matchedFields = [];
            // I hate javascript
            var fields = getFields(item.obj.clazz).concat({
                fieldName: 'guid',
                memberType: 'STRING'
            });
            var match = true;

            // go through query terms, EACH must get a match otherwise the query fails
            for (var k = 0; k < queryTerms.length; k++) {
                var queryTerm = queryTerms[k];
                if (queryTerm.length == 0) continue;
                var matches = 0;

                for (var l = 0; l < fields.length; l++) {
                    var field = fields[l];
                    var fieldType = field.memberType;
                    if (fieldType != 'STRING' || field.array) continue; // TODO: search arrays?

                    var fieldName = field.fieldName;
                    var fieldVal = item.obj[fieldName];
                    if (!fieldVal) continue;

                    if (fieldVal.toLowerCase().indexOf(queryTerm.toLowerCase()) != -1) {
                        matches++;
                        item.matchedFields.push(fieldName);
                        break;
                    }
                }

                if (!matches) {
                    match = false;
                    break;
                }
            }

            if (match) groupResultArr.push(item);
        }
        if (groupResultArr.length) results.push({ text: group.text, children: groupResultArr });
    }
    return results;
}

function objCollectionAndGuid(obj) {
    return obj.ffRL + "/" + obj.guid;
}

function addTablesToElement(tables, element)
{
    for (var i = 0; i < tables.length; i++)
        $(element).append(tables[i]);
}

function createSummaryTables(objList)
{
    var tables = [];

    var clazzLists = {};

    var i = 0;
    for (i = 0; i < objList.length; i++)
    {
        var obj = objList[i];
        if (obj === ffdb_mainViewModel.blank)
            continue;
        if (! clazzLists[obj.clazz])
            clazzLists[obj.clazz] = [];
        clazzLists[obj.clazz].push(obj);
    }

    var clazz;
    for (clazz in clazzLists)
    {
        var fields = getFields(clazz);

        var theTable = createSummaryTable(fields, clazzLists[clazz]);

        tables.push(theTable);
    }

    return tables;
}

function createSummaryTable(fields, objList)
{
    var theTable = $("<table class='table2'></table>");

    var tHead = document.createElement("thead");
    $(tHead).append(createSummaryTableHeaderRow(fields));
    $(theTable).append(tHead);

    var tBody = document.createElement("tbody");
    for (var i = 0 ; i < objList.length; i++) {
        if (objList[i] === ffdb_mainViewModel.blank)
            continue;
        $(tBody).append(createSummaryTableRow(objList[i], fields));
    }
    $(theTable).append(tBody);

    return theTable;
}

function createSummaryTableHeaderRow(fields) {
    var hr = document.createElement('tr');

    var i = 0;
    var fieldType;
    var th;

    // create a th element for the 'detail' button
    $(hr).append("<th></th>");

    // create a th element for this object's collection name
    $(hr).append("<th>Collection</th>");

    // now append one td element for every member we know of for this clazz
    // first, the blobs
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType != 'BYTEARRAY')
            continue;

        th = $("<th>" + fields[i].fieldName + "</th>");
        $(hr).append(th);
    }

    // then, all the 'normal' members
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType == 'REFERENCE' || fieldType == 'GRABBAG' || fieldType == 'BYTEARRAY')
            continue;

        th = $("<th>" + fields[i].fieldName + "</th>");
        $(hr).append(th);
    }
    // then, all the references
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType != 'REFERENCE')
            continue;

        th = $("<th>" + fields[i].fieldName + "</th>");
        $(hr).append(th);
    }
    // then, all the grab bags
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType != 'GRABBAG')
            continue;

        th = $("<th>" + fields[i].fieldName + "</th>");
        $(hr).append(th);
    }

    return hr;
}

function getDisplayString (value, fieldMetaData) {
    if (value == null)
        return null;

    if (fieldMetaData.memberType == 'DATE') {
        if (fieldMetaData.array) {
            var arr = [];
            for (var i = 0; i < value.length; i++) {
                arr.push(ISODateString(new Date(value[i])));
            }
            return JSON.stringify(arr);
        } else {
            return ISODateString(new Date(value));
        }
    }

    return JSON.stringify(value);
}

function createSummaryTableRow (obj, fields) {
    // TODO this function is in dire need of refactoring
    var tr = $("<tr></tr>");

    var i = 0;
    var fieldName;
    var fieldType;
    var mimeType;
    var td;
    var linkUrl;
    var anchor;

    // create a td element for the 'detail' button
    var detailButton = $("<button class='btn btn-small'>Detail</button>");
    $(detailButton).attr("onclick", "displayDetailPanel('" + obj.ffUrl + "')");
    var detailTd = $("<td></td>");
    $(detailTd).append(detailButton);
    $(tr).append(detailTd);

    // create a td element for this object's collection name
    var collectionTd = $("<td>" + obj.ffRL + "</td>");
    $(tr).append(collectionTd);

    // now append one td element for every member we know of for this clazz
    // first, the blobs
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType != 'BYTEARRAY')
            continue;

        fieldName = fields[i].fieldName;
        mimeType = fields[i].mimeType || "null";

        // If it's an image, show an image element
        if (mimeType.indexOf("image") == 0) {
            var imageEl = $("<img width='30px' height='45px'/>");
            $(imageEl).attr("src", ff.getBaseUrl() + obj.ffUrl + "/" + fieldName);
            td = $("<td></td>");
            $(td).append(imageEl);
        }
        // TODO If it's a video, show a video element
        else if (mimeType.indexOf("video") == 0) {
            linkUrl = ff.getBaseUrl() + obj.ffUrl + "/" + fieldName;
            td = $("<td><a href='" + linkUrl + "'>" + linkUrl + "</a></td>");
        }
        // TODO If it's audio, show an audio element
        else if (mimeType.indexOf("audio") == 0) {
            linkUrl = ff.getBaseUrl() + obj.ffUrl + "/" + fieldName;
            td = $("<td><a href='" + linkUrl + "'>" + linkUrl + "</a></td>");
        }
        else // otherwise, let's display a link
        {
            linkUrl = ff.getBaseUrl() + obj.ffUrl + "/" + fieldName;
            td = $("<td><a href='" + linkUrl + "' target='_blank'>Show</a></td>");
        }
        $(tr).append(td);
    }

    // then, all the 'normal' members
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType == 'REFERENCE' || fieldType == 'GRABBAG' || fieldType == 'BYTEARRAY')
            continue;

        fieldName = fields[i].fieldName;
        td = $("<td>" + getDisplayString(obj[fieldName], fields[i]) + "</td>");

        $(tr).append(td);
    }
    // then, all the references
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType != 'REFERENCE')
            continue;

        fieldName = fields[i].fieldName;

        // if this reference is non-null, then let's display a link which will display the reference in the main table when clicked
        if (obj[fieldName] != null) {
            var referredUrl = obj[fieldName].ffUrl;
            anchor = $("<A href='#'>Show</A>");
//            $(anchor).append(referredUrl);
            $(anchor).click(createDisplayReferenceFunction(referredUrl));

            td = $("<td></td>");
            $(td).append(anchor);
            $(tr).append(td);
        }
        else {
            $(tr).append($("<td></td>"));
        }
    }

    // then, all the grab bags
    for (i = 0; i < fields.length; i++) {
        fieldType = fields[i].memberType;
        if (fieldType != 'GRABBAG')
            continue;

        fieldName = fields[i].fieldName;

        // let's display a link which will pop up a panel with a list of objects in the grab bag when clicked
        linkUrl = obj.ffUrl + "/" + fieldName;
        anchor = $("<A href='#'>Show</A>");
//        $(anchor).append(linkUrl);
        $(anchor).click(createDisplayGrabbagFunction(linkUrl));

        td = $("<td></td>");
        $(td).append(anchor);
        $(tr).append(td);
    }

    // now set the title to a stringified version of the object's metadata
    $(tr).prop("title", getToolTip(obj));

    return tr;
}

function createDisplayReferenceFunction(url) {
    return function(event) {
        event.preventDefault();
        displayReference(url);
    }
}

function createDisplayGrabbagFunction(url) {
    return function(event) {
        event.preventDefault();
        displayGrabBag(url);
    }
}

function deleteObject(ffUrl) {
    if (confirm("Really delete this object?")) {
        var obj = ff.getFromInMemCache(ffUrl);
        ff.deleteObj(obj, function(statusMessage) {
            ffdb_mainViewModel.queryResults.remove(obj);
            ffdb_mainViewModel.detailVisible(false);
            ffdb_mainViewModel.tableVisible(true);
            ffdb_mainViewModel.updateQueryHistoryButtons();
            toast("Delete successful: " + statusMessage);
        }, function (statusCode, statusMessage) {
            var msg = "Delete request failed with status code " + statusCode + " statusMessage " + statusMessage;
            toastError(msg);
        });
    }
}

function updateObject(obj, grabbags) {
    ff.updateObj(obj, function(returnedData, statusMessage) {
        handleGrabbags(obj, grabbags, function() {
            ffdb_mainViewModel.resultRowUpdated(obj);
            ffdb_mainViewModel.detailVisible(false);
            ffdb_mainViewModel.tableVisible(true);
            ffdb_mainViewModel.updateQueryHistoryButtons();
            toast("Update successful: " + statusMessage);
        });
    }, function (statusCode, statusMessage) {
        var msg = "Update request failed with status code " + statusCode + " statusMessage " + statusMessage;
        toastError(msg);
    });
}

/**
 * Recursive function to go through 'fieldValues' looking for things that need asynchronous processing (like files) and replacing them with the processed value.
 * @param obj
 * @param grabbags
 */
function prepFieldsAndCreateObject(obj, grabbags) {
    for (var key in obj) {
        if (!obj[key]) continue;

        if (obj[key].file) {
            // this field is a blob, read from file
            // TODO: UI while loading
            var file = obj[key].file;
            var reader = new FileReader();
            reader.onerror = function(event) {
                var msg = "Error reading file: ";
                switch(event.target.error.code) {
                    case 1:
                        msg += "file not found";
                        break;
                    case 2:
                        msg += "file changed on disk, please re-try";
                        break;
                    case 3:
                        msg += "upload cancelled";
                        break;
                    case 4:
                        msg += "cannot read file";
                        break;
                    case 5:
                        msg += "file too large for browser to upload";
                        break;
                }
                console.error(msg);
                toastError(msg);
            };
            reader.onload = function(event) {
                obj[key] = event.target.result;
                prepFieldsAndCreateObject(obj, grabbags);
            };
            reader.readAsArrayBuffer(file);
            return;
        }
    }

    // when we get here, that means there are no more fields to process, so we can go ahead and create the object
    createObject(obj, grabbags);
}

/**
 * Lamentably similar to above
 * @param obj
 * @param fieldValues
 */
function updateBlobFieldsAndObject(obj, grabbags) {
    for (var key in obj) {
        if (!obj[key]) continue;

        if (obj[key].file) {
            // this field is a blob, read from file
            // TODO: UI while loading
            var file = obj[key].file;
            var reader = new FileReader();
            reader.onerror = function(event) {
                var msg = "Error reading file: ";
                switch(evt.target.error.code) {
                    case 1:
                        msg += "file not found";
                        break;
                    case 2:
                        msg += "file changed on disk, please re-try";
                        break;
                    case 3:
                        msg += "upload cancelled";
                        break;
                    case 4:
                        msg += "cannot read file";
                        break;
                    case 5:
                        msg += "file too large for browser to upload";
                        break;
                }
                console.error(msg);
                toastError(msg);
            };
            reader.onload = (function(key) {
                return function(event) {
                    delete obj[key];
                    var blob = event.target.result;

                    ff.updateBlobForObj(obj, blob, key, null, function(result) {
                        updateBlobFieldsAndObject(obj, grabbags);
                    }, function(errCode, errMsg) {
                        var msg = "Error " + errCode + ": " + errMsg;
                        toastError(msg);
                        console.error(msg);
                    });
                };
            })(key);

            reader.readAsArrayBuffer(file);
            return;
        }
    }

    // when we get here, that means there are no more fields to process, so we can go ahead and update the object
    updateObject(obj, grabbags);
}

function createObject(obj, grabbags) {
    ff.createObjAtUri(obj, obj.ffRL, function(returnedData, statusMessage) {
        handleGrabbags(obj, grabbags, function() {
            ffdb_mainViewModel.detailVisible(false);
            ffdb_mainViewModel.tableVisible(true);
            $('#input_queryText').val(obj.ffRL);
            ffdb_mainViewModel.submitQuery();
            toast("Create successful: " + statusMessage);
        });
    }, function (statusCode, statusMessage) {
        var msg = "Update request failed with status code " + statusCode + " statusMessage " + statusMessage;
        toastError(msg);
    });
}

function handleGrabbags(obj, grabbags, successCallback) {
    var gb, item;

    // additions
    for (gb in grabbags.add) {
        item = grabbags.add[gb].shift();
        if (item) {
            ff.grabBagAdd({ ffUrl: item }, obj, gb, function() {
                handleGrabbags(obj, grabbags, successCallback);
            }, function(errCode, errMsg) {
                var msg = "Error " + errCode + ": " + errMsg;
                toastError(msg);
                console.error(msg);
            });
            return;
        }
    }

    // deletions
    for (gb in grabbags.remove) {
        item = grabbags.remove[gb].shift();
        if (item) {
            ff.grabBagRemove({ ffUrl: item }, obj, gb, function() {
                handleGrabbags(obj, grabbags, successCallback);
            }, function(errCode, errMsg) {
                var msg = "Error " + errCode + ": " + errMsg;
                toastError(msg);
                console.error(msg);
            });
            return;
        }
    }

    // done
    successCallback();
}

function displayReference (referenceUrl) {
    ffdb_mainViewModel.query(referenceUrl);
}

function displayGrabBag (grabBagUrl) {
    ffdb_mainViewModel.query(grabBagUrl);
}

function displayDetailPanel (ffUrl) {
    var obj = ff.getFromInMemCache(ffUrl);

    ffdb_mainViewModel.detailObject(new ObjectWrapper(obj));
    ffdb_mainViewModel.tableVisible(false);
    ffdb_mainViewModel.detailVisible(true);
    ffdb_mainViewModel.updateQueryHistoryButtons();
}

function displayDetailPanel_createObj(obj) {
    ffdb_mainViewModel.detailObject(new ObjectWrapper(obj));
    ffdb_mainViewModel.tableVisible(false);
    ffdb_mainViewModel.detailVisible(true);
    ffdb_mainViewModel.updateQueryHistoryButtons();
}


function getFields(clazz) {
    var objTypes = ffdb_mainViewModel.mdObjectTypes();
    for (var i = 0; i < objTypes.length; i++) {
        if (objTypes[i].objectTypeName == clazz)
            return objTypes[i].fields;
    }
    throw new Error("Could not find ObjectType for clazz " + clazz);
}

// will need inverse of this -- see http://momentjs.com/
function ISODateString(d) {
    function pad(n){
        return n < 10 ? '0'+n : n
    }
    return d.getUTCFullYear()+'-'
    + pad(d.getUTCMonth()+1)+'-'
    + pad(d.getUTCDate())+' '
    + pad(d.getUTCHours())+':'
    + pad(d.getUTCMinutes())+':'
    + pad(d.getUTCSeconds())+'.'
    + pad(d.getUTCMilliseconds())+' Z'
}

function shorten(s) {
    if (s.length <= 20)
        return s;
    else
        return s.substring(0, 17) + "...";
}

function ffdb_resizeDivs() {
    var availableHeight = $(window).height() - $("#navbar").outerHeight() - $("#headerContainer").outerHeight() - 30;

    var height, width;

    // collectionList needs to have height of window - navbar - headerContainer
    var target = $('#collectionList');
    height = availableHeight;
    target.css('height', height);

    var centerHeaderContainer = $("#centerHeaderContainer");

    // centerColumnTargetContainer needs to have height of window - navbar - headerContainer - height of centerHeaderContainer
    // It needs width
    target = $('#centerColumnTargetContainer');
    height = availableHeight - centerHeaderContainer.outerHeight() - 23;
    width = $('#bodyTargetContainer').outerWidth() - $('#leftColumnContainer').outerWidth() - 20;
    target.css('height', height);
    target.css('width', width);

    // input_queryText needs to have width of centerHeaderContainer - width of btn_executeQuery
    target = $('#input_queryText');
    width = centerHeaderContainer.outerWidth() - $("#btn_executeQuery").outerWidth() - $("#btn_queryBack").outerWidth() - $("#btn_queryForward").outerWidth() - 20;
    target.css('width', width);
}

// happens too quickly, too big
function getToolTip (obj) {
    var tt = {};

    tt.editable = obj.ffUserCanEdit;

    tt.ffUrl = obj.ffUrl;
    tt.guid = obj.guid;
    tt.version = obj.version;

    tt.createdAt = ISODateString(new Date(obj.createdAt));
    tt.createdBy = obj.createdBy;

    tt.updatedAt = ISODateString(new Date(obj.updatedAt));
    tt.updatedBy = obj.updatedBy;

    return JSON.stringify(tt, null, 2);
}

function getAltToolTip (obj) {
    var tt = {};
    var fields = getFields(obj.clazz);
    for (var i = 0; i < fields.length; i++) {
        switch (fields[i].memberType) {
            case 'BOOLEAN':
            case 'DATE':
            case 'STRING':
            case 'NUMERIC':
                tt[fields[i].fieldName] = obj[fields[i].fieldName];
        }
    }

    return JSON.stringify(tt, null, 2);
}

function getHtmlJson(obj, matchedFields) {
    if (!matchedFields) matchedFields = [];
    var result;
    if ($.inArray('guid', matchedFields) != -1) {
        result = "<b>" + obj.guid + "</b>";
    } else {
        result = obj.guid;
    }
    var fields = getFields(obj.clazz);
    for (var i = 0; i < fields.length; i++) {
        var fieldName = fields[i].fieldName;
        switch (fields[i].memberType) {
            case 'STRING':
                var text = fieldName + ": " + obj[fieldName];
                var match = $.inArray(fieldName, matchedFields) != -1;
                if (match) text = "<b>" + text + "</b>";
                if (matchedFields.length > 0) result += "<br/>" + text;
        }
    }

    return result;
}

function ObjectWrapper(obj, canEdit) {
    var self = this;

    self.obj = obj;
    self.newObj = (obj.ffUrl === undefined);
    if (canEdit === undefined) {
        self.canEdit = obj.ffUserCanEdit || self.newObj;
    } else {
        self.canEdit = canEdit;
    }

    self.fields = getFields(obj.clazz);

    self.fieldVals = {};
    self.stagedFieldVals = {}; // for values where a control state isn't directly linked to a member value, e.g. for a grabbag we have a menu that controls the value of an item that is staged for addition to the grabbag list -- the control is linked to the stage, not to the grabbag itself
    self.origFieldVals = {};
    self.fieldExpanded = {};
    self.fieldLoaded = {};

    for (var i = 0; i < self.fields.length; i++) {
        var field = self.fields[i];
        var fieldName = field.fieldName;
        switch (self.fields[i].memberType) {
            case 'BYTEARRAY':
                if (field.array) {
                    self.fieldVals[fieldName] = new ko.observableArray();
                    self.fieldExpanded[fieldName] = new ko.observable(false);
                } else {
                    self.fieldVals[fieldName] = new ko.observable(null);
                }
                break;
            case 'REFERENCE':
                self.fieldVals[fieldName] = new ko.observable(self.obj[fieldName] ? self.obj[fieldName].ffUrl : null);
                break;
            case 'GRABBAG':
                self.fieldVals[fieldName] = new ko.observableArray();
                self.origFieldVals[fieldName] = null;
                self.stagedFieldVals[fieldName] = new ko.observable(null);
                self.fieldExpanded[fieldName] = new ko.observable(false);
                self.fieldLoaded[fieldName] = new ko.observable(false);
                break;
            case 'GEOLOCATION':
                if (field.array) {
                    self.fieldVals[fieldName] = new ko.observableArray([]);
                    // TODO: finish
                } else {
                    self.fieldVals[fieldName] = {
                        latitude:           new ko.observable(self.obj[fieldName] ? self.obj[fieldName].latitude : null),
                        longitude:          new ko.observable(self.obj[fieldName] ? self.obj[fieldName].longitude : null),
                        altitude:           new ko.observable(self.obj[fieldName] ? self.obj[fieldName].altitude : null),
                        accuracy:           new ko.observable(self.obj[fieldName] ? self.obj[fieldName].accuracy : null),
                        altitudeAccuracy:   new ko.observable(self.obj[fieldName] ? self.obj[fieldName].altitudeAccuracy : null),
                        heading:            new ko.observable(self.obj[fieldName] ? self.obj[fieldName].heading : null),
                        speed:              new ko.observable(self.obj[fieldName] ? self.obj[fieldName].speed : null)
                    };
                }
                break;
            case 'OBJECT':
                var blank = { clazz: self.fields[i].objectTypeName };
                if (field.array) {
                    self.fieldVals[fieldName] = new ko.observableArray([]);
                    var arr = self.obj[fieldName];
                    if (arr) {
                        for (var j = 0; j < arr.length; j++) {
                            self.fieldVals[fieldName].push({ value: new ko.observable(new ObjectWrapper(arr[j], self.canEdit)) });
                        }
                    }
                    self.stagedFieldVals[fieldName] = new ko.observable(new ObjectWrapper(blank, self.canEdit));
                    self.fieldExpanded[fieldName] = new ko.observable(false);
                } else {
                    self.fieldVals[fieldName] = new ko.observable(new ObjectWrapper(self.obj[fieldName] ? self.obj[fieldName] : blank, self.canEdit));
                }
                break;
            default:
                // need to make these observable so that the values can be set within custom bindings
                if (field.array) {
                    self.fieldVals[fieldName] = new ko.observableArray([]);
                    arr = self.obj[fieldName];
                    if (arr) {
                        for (j = 0; j < arr.length; j++) {
                            self.fieldVals[fieldName].push({ value: new ko.observable(arr[j]) });
                        }
                    }
                    self.stagedFieldVals[fieldName] = new ko.observable();
                    self.fieldExpanded[fieldName] = new ko.observable(false);
                } else {
                    self.fieldVals[fieldName] = new ko.observable(self.obj[fieldName]);
                }
        }
    }

    self.showField = function(fieldObj) {
        var field = fieldObj.fieldName;
        if (fieldObj.memberType == 'GRABBAG' && !self.fieldLoaded[field]()) {
            if (self.obj.ffUrl) {
                self.loadGrabbag(fieldObj);
            } else {
                self.fieldLoaded[field] = true;
            }
        }
        self.fieldExpanded[field](true);
    };

    self.hideField = function(fieldObj) {
        var field = fieldObj.fieldName;
        self.fieldExpanded[field](false);
    };

    self.loadGrabbag = function(fieldObj) {
        var field = fieldObj.fieldName;
        if (fieldObj.memberType != 'GRABBAG') {
            console.error("loadGrabbag called on non-grabbag member!");
            return;
        }
        var array = self.fieldVals[field];
        var origArray = self.origFieldVals[field] = [];
        var loaded = self.fieldLoaded[field];
        ff.grabBagGetAll(self.obj, field, function(result) {
            loaded(true);
            for (var i = 0; i < result.length; i++) {
                array.push(result[i].ffUrl);
                origArray.push(result[i].ffUrl);
            }
        }, function(errCode, errMsg) {
            var msg = "Error " + errCode + ": " + errMsg;
            toastError(msg);
            console.error(msg);
        });
    };

    self.addStageToField = function(fieldObj) {
        var fieldName = fieldObj.fieldName;
        var stagedVal = self.stagedFieldVals[fieldName];
        var val = self.fieldVals[fieldName];
        if (!stagedVal()) {
            if (fieldObj.memberType == 'BOOLEAN') {
                // null can mean the checkbox is empty, so set the value here and allow it to be added
                stagedVal(false);
            } else {
                return;
            }
        }
        if (fieldObj.memberType == 'GRABBAG') {
            if ($.inArray(stagedVal(), val()) == -1) val.push(stagedVal());
        } else {
            val.push({ value: new ko.observable(stagedVal()) });    // can't just give it stagedVal, because it's a reference; this copies the value which is what we need
        }

        if (fieldObj.memberType == 'GEOLOCATION') {
            stagedVal(new ObjectWrapper({ clazz: 'FFGeoLocation' }, self.canEdit));
        } else if (fieldObj.memberType == 'OBJECT') {
            stagedVal(new ObjectWrapper({ clazz: fieldObj.objectTypeName }, self.canEdit));
        } else {
            stagedVal(null);
        }
    };

    self.removeFromField = function(val, fieldObj) {
        var fieldName = fieldObj.fieldName;
        if (fieldObj.memberType == 'GRABBAG') {
            self.fieldVals[fieldName].remove(val);
        } else {
            self.fieldVals[fieldName].splice(val, 1);
        }
    };

    self.prepare = function() {
        var grabbags = { add: {}, remove: {} };
        for (var i = 0; i < self.fields.length; i++) {
            var fieldName = self.fields[i].fieldName;
            var valAccessor = self.fieldVals[fieldName];
            var rawVal, val;
            if (valAccessor) {
                switch (self.fields[i].memberType) {
                    case 'BYTEARRAY':
                        // TODO: handle arrays?
                        if (valAccessor()) {
                            self.obj[fieldName] = { file: valAccessor() };
                        }
                        break;
                    case 'REFERENCE':
                        if (valAccessor()) {
                            rawVal = { ffUrl: valAccessor() };
                        } else {
                            rawVal = null;
                        }
                        self.obj[fieldName] = rawVal;
                        break;
                    case 'GRABBAG':
                        if (valAccessor() && fieldName != 'BackReferences') {
                            rawVal = valAccessor();
                            var origVal = self.origFieldVals[fieldName];

                            if (origVal) {
                                var toAdd = rawVal.diff(origVal);
                                var toRemove = origVal.diff(rawVal);
                            } else {
                                toAdd = rawVal;
                                toRemove = [];
                            }

                            grabbags.add[fieldName] = toAdd;
                            grabbags.remove[fieldName] = toRemove;
                        }
                        break;
                    case 'GEOLOCATION':
                        if (self.fields[i].array) {
                            // nothing
                        } else {
                            rawVal = valAccessor;
                            console.log("rawVal = ", rawVal);
                            self.obj[fieldName] = {
                                latitude:           Number(rawVal.latitude()),
                                longitude:          Number(rawVal.longitude()),
                                altitude:           Number(rawVal.altitude()),
                                accuracy:           Number(rawVal.accuracy()),
                                altitudeAccuracy:   Number(rawVal.altitudeAccuracy()),
                                heading:            Number(rawVal.heading()),
                                speed:              Number(rawVal.speed())
                            };
                        }
                        break;
                    case 'OBJECT':
                        rawVal = valAccessor();
                        if (self.fields[i].array) {
                            val = [];
                            for (j = 0; j < rawVal.length; j++) {
                                rawVal[j].value().prepare();
                                val.push(rawVal[j].value().obj);
                            }
                        } else {
                            rawVal.prepare();
                            val = rawVal.obj;
                        }
                        self.obj[fieldName] = val;
                        break;
                    case 'NUMERIC':
                    case 'DATE':
                        rawVal = valAccessor();
                        if (self.fields[i].array) {
                            val = [];
                            for (j = 0; j < rawVal.length; j++) {
                                val.push(Number(rawVal[j].value()));
                            }
                        } else {
                            val = Number(rawVal);
                        }
                        self.obj[fieldName] = val;
                        break;
                    default:
                        rawVal = valAccessor();
                        if (self.fields[i].array) {
                            val = [];
                            for (j = 0; j < rawVal.length; j++) {
                                val.push(rawVal[j].value());
                            }
                        } else {
                            val = rawVal;
                        }
                        self.obj[fieldName] = val;
                }
            }
        }
        return grabbags;
    };

    self.submit = function() {
        var grabbags = self.prepare();

        if (self.newObj) {
            prepFieldsAndCreateObject(self.obj, grabbags);
        } else {
            updateBlobFieldsAndObject(self.obj, grabbags);
        }
    };

    self.deleteObj = function() {
        deleteObject(self.obj.ffUrl);
    };
}

var ffdb_mainViewModel = {
    current: null,

    userName: new ko.observable(""), password: new ko.observable(""),
    firstName: new ko.observable(""), lastName: new ko.observable(""), email: new ko.observable(""),

    mdCollections : new ko.observableArray(),
    mdObjectTypes : new ko.observableArray(),
    mdSettings    : new ko.observable(),

    allowNewCollections : new ko.observable(true),

    tableVisible : new ko.observable(false),
    detailVisible : new ko.observable(false),

    // TODO: bug in here somewhere re: getBaseUrl and when it's called, be careful
    baseUrl : new ko.observable(ff.getBaseUrl()),

    loggedInUserName : new ko.observable(ff.loggedInUser() ? ff.loggedInUser().userName : null),

    loggedInUserFirstLastName : new ko.observable(ff.loggedInUser() ? "Logged in as - " + ff.loggedInUser().firstName +  " " + ff.loggedInUser().lastName : "Anonymous"),
    logInOutButtonText : new ko.observable(ff.loggedIn() ? "LOGOUT":"LOGIN"),

    queryResults : new ko.observableArray(),
    detailObject : new ko.observable(null),

    debug : new ko.observable(false),

    mayResetAppUrl: true,
    shouldResetAppUrl: false,

    blank: {},
    resultRowUpdated: function(obj) {
        // force KO to reload this row only
        ffdb_mainViewModel.queryResults.replace(obj, ffdb_mainViewModel.blank);
        ffdb_mainViewModel.queryResults.replace(ffdb_mainViewModel.blank, obj);
    },

    setAppUrl: function(formElement) {
        var appUrl = $('#input_appUrl').val();
        if (appUrl == "")
            return;

        var baseUrl = ff.getBaseUrl();
        if (baseUrl != appUrl) {
            toast("Pointing data browser to new backend: " + appUrl);
            ffdb_mainViewModel.userName(""); ffdb_mainViewModel.password(""); ffdb_mainViewModel.loggedInUserName("");
            ffdb_mainViewModel.firstName(""); ffdb_mainViewModel.lastName(""); ffdb_mainViewModel.email("");
            ffdb_mainViewModel.queryResults([]); ffdb_mainViewModel.detailObject(null);
            ffdb_mainViewModel.mdCollections([]); ffdb_mainViewModel.mdObjectTypes([]); ffdb_mainViewModel.mdSettings({});
            ffdb_mainViewModel.allowNewCollections(true); ffdb_mainViewModel.tableVisible(false); ffdb_mainViewModel.detailVisible(false);
            ffdb_mainViewModel.current = null;
            ff.setBaseUrl(appUrl);
            ff.setSSLUrl(appUrl);
            ffdb_mainViewModel.loggedInUserName(ff.loggedInUser() ? ff.loggedInUser().userName : "");
            ffdb_mainViewModel.loggedInUserFirstLastName(ff.loggedInUser() ? ff.loggedInUser().firstName + " " + ff.loggedInUser().lastName : null);
            ffdb_mainViewModel.baseUrl(ff.getBaseUrl());
            ffdb_mainViewModel.reloadMetaData();
        }
    },

    initDataBrowser: function() {
        $("#imgAjaxLoader").ajaxStart(
            function() {
                $(this).show();
            }).ajaxStop(function() {
                $(this).hide();
            });

        $('#login-dialog').on('shown', function() {
            $('#input_userName').focus();
        });

        ff.setBaseUrl(ff.getBaseUrl());
        ff.setSimulateCookies(true);

        var providedBaseUrl = getParameterByName("baseUrl");
        if (providedBaseUrl.length > 0 && /^(http:\/\/|https:\/\/)/.test(providedBaseUrl)) {
            $('#input_appUrl').val(providedBaseUrl);
        }

        ffdb_mainViewModel.setAppUrl();

        ffdb_mainViewModel.baseUrl(ff.getBaseUrl());
        ffdb_mainViewModel.reloadMetaData();

        // reset app URL text input to current base URL when it loses focus,
        // UNLESS there's a mousedown in the "change app URL" button
        // HOWEVER, if you mouse out of the button while the mouse is still
        // clicked, then reset the app URL after all (ugh)
        $('#input_appUrl').blur(function() {
            if (ffdb_mainViewModel.mayResetAppUrl) {
                ffdb_mainViewModel.baseUrl(ff.getBaseUrl());
            } else {
                ffdb_mainViewModel.shouldResetAppUrl = true;
            }
        });
        $('#btn_appUrl').mousedown(function() {
            ffdb_mainViewModel.mayResetAppUrl = false;
        });
        $('#btn_appUrl').mouseleave(function() {
            if (ffdb_mainViewModel.shouldResetAppUrl) {
                ffdb_mainViewModel.baseUrl(ff.getBaseUrl());
                ffdb_mainViewModel.shouldResetAppUrl = false;
            }
        });
        $(document).mouseup(function() {
            ffdb_mainViewModel.mayResetAppUrl = true;
        });

        $("body").keydown(function(e) {
            var hasFocusId = ($( document.activeElement ).attr('id'));
            if (hasFocusId == null || hasFocusId.indexOf("input_") != 0) {
                if (e.keyCode == 37) { // left
                    ffdb_mainViewModel.queryHistoryBack();
                }
                else if (e.keyCode == 39) { // right
                    ffdb_mainViewModel.queryHistoryForward();
                }
            }
        });

        ffdb_mainViewModel.updateQueryHistoryButtons();
    },

    queryHistoryForward: function() {
        if (!ffdb_mainViewModel.detailVisible()) {
            if (ffdb_mainViewModel.current != null) {
                if (ffdb_mainViewModel.current.nextPtr != null) {
                    toast("Next (" + ffdb_mainViewModel.current.nextPtr.queryText + ")", false, 100);
                    ffdb_mainViewModel.queryResults (ffdb_mainViewModel.current.nextPtr.queryResults);
                    $('#input_queryText').val(ffdb_mainViewModel.current.nextPtr.queryText);
                    ffdb_mainViewModel.current = ffdb_mainViewModel.current.nextPtr;
                }
            }
        }
        ffdb_mainViewModel.updateQueryHistoryButtons();
    },

    queryHistoryBack: function() {
        if (!ffdb_mainViewModel.detailVisible()) {
            if (ffdb_mainViewModel.current != null) {
                if (ffdb_mainViewModel.current.previous != null) {
                    toast("Previous (" + ffdb_mainViewModel.current.previous.queryText + ")", false, 100);
                    ffdb_mainViewModel.queryResults (ffdb_mainViewModel.current.previous.queryResults);
                    $('#input_queryText').val(ffdb_mainViewModel.current.previous.queryText);
                    ffdb_mainViewModel.current = ffdb_mainViewModel.current.previous;
                }
            }
        }
        ffdb_mainViewModel.updateQueryHistoryButtons();
    },

    updateQueryHistoryButtons: function() {
        var back = $('#btn_queryBack');
        var forward = $('#btn_queryForward');
        if (ffdb_mainViewModel && ffdb_mainViewModel.current && !ffdb_mainViewModel.detailVisible()) {
            if (ffdb_mainViewModel.current.previous != null) {
                back.removeClass("disabled");
            }
            else back.addClass("disabled");
            if (ffdb_mainViewModel.current.nextPtr != null) forward.removeClass("disabled");
            else forward.addClass("disabled");
        } else {
            back.addClass("disabled");
            forward.addClass("disabled");
        }
    },

    collectionQuery: function(collectionName) {
        $('#input_queryText').val(collectionName);
        ffdb_mainViewModel.submitQuery();
    },

    submitQuery: function() {
        queryText = $('#input_queryText').val();
        ffdb_mainViewModel.query(queryText);
    },

    query: function(queryText) {
        ffdb_mainViewModel.tableVisible(true);
        ffdb_mainViewModel.detailVisible(false);

        $('#input_queryText').val(queryText);

        var previous = ffdb_mainViewModel.current;
        ffdb_mainViewModel.current = {queryText: queryText, previous: previous, queryResults: ffdb_mainViewModel.queryResults()};
        if (previous != null)
            previous.nextPtr = ffdb_mainViewModel.current;

        if (queryText.indexOf("/") != 0)
            queryText = "/" + queryText;
        if (queryText.indexOf("/ff/") != 0)
            queryText = "/ff/resources" + queryText;

        $('#imgAjaxLoader').show();

        ffdb_mainViewModel.queryResults([]);

        ff.getArrayFromUri(queryText,
            function(returnedData, statusMessage) {
                toast(statusMessage);
                ffdb_mainViewModel.queryResults(returnedData);
                ffdb_mainViewModel.current.queryResults = returnedData;
                ffdb_mainViewModel.updateQueryHistoryButtons();

                $('#imgAjaxLoader').hide();
            }, function(statusCode, statusMessage) {
                var msg = "Get request failed with status code " + statusCode + " statusMessage " + statusMessage;
                toastError(msg);

                $('#imgAjaxLoader').hide();
            });

        return false;
    },

    newObject: function(typeName, collectionName) {
//        toast ("Would create a new object of type " + typeName + " in collection " + collectionName);

        var obj = {
            clazz: typeName,
            ffRL: collectionName
        };
        displayDetailPanel_createObj(obj);
    },

    // TODO: kind of hokey, should RUN FFDL
    addNewCollection: function() {
        if (ffdb_mainViewModel.allowNewCollections())
        {
            var collectionName = $('#input_newCollectionName').val();
            if (collectionName.indexOf("/") != 0)
                collectionName = "/" + collectionName;

            var tempObj = {clazz:"FFUser"};
            ff.createObjAtUri(tempObj, collectionName, function(returnedData, statusMessage) {
                    toast("Collection " + collectionName + " added");
                    ffdb_mainViewModel.reloadMetaData();
                    ff.deleteObj(tempObj);
                }, function(statusCode, statusMessage) {
                var msg = "Failed to create object in new collection: status code: " + statusCode + " statusMessage: " + statusMessage;
                toastError(msg);
            });


        }

        return false;
    },

    // TODO: reload metadata on login/logout? something to disallow edits on logout
    reloadMetaData : function() {
        var url = ff.getBaseUrl() + "ff/metadata";
        $.ajax({
            type: "GET",
            url: url,
            dataType: 'json',
            success: function(response) {
                ffdb_mainViewModel.mdCollections(response.result.collectionResources);
                $(function() {
                    $('.highlightWhenHover').hover(function() {
                        $(this).addClass('yellow');
                    }, function() {
                        $(this).removeClass('yellow');
                    });
                });

                ffdb_mainViewModel.mdObjectTypes(response.result.objectTypes);
                ffdb_mainViewModel.mdSettings(response.result.settings);

//                ffdb_mainViewModel.allowNewCollections(response.result.settings.AllowNewCollections === 'true');
            },
            error: function(jqXHR, textStatus, errorThrown) {
                var msg;
                if (jqXHR.status == 0)
                    msg = "Load metadata request failed - likely a cross-origin access failure - check your browser console";
                else
                    msg = "Load metadata request failed - response code was " + jqXHR.status + " responseText was " + jqXHR.responseText
                        + " - status is " + textStatus + " error is " + errorThrown;
                console.error(msg);
                toastError(msg);
            }

        });
    },
    logInOut: function() {
        if(ff.loggedIn()) {
            ffdb_mainViewModel.logout();
        } else {
            ffdb_mainViewModel.showLogin();

        }
    },
    login: function() {
        if ($('#viaConsole').is(':checked')) {
            ff.loginUsingConsoleCredentials (ffdb_mainViewModel.userName(), ffdb_mainViewModel.password(),
                    function(loggedInUser) {
                        var statusMessage = "Successfully logged in as " + loggedInUser.userName;
                        toast (statusMessage);
                        ffdb_mainViewModel.userName(loggedInUser.userName);
                        ffdb_mainViewModel.loggedInUserName(loggedInUser.userName);

                        ffdb_mainViewModel.reloadMetaData();

                        $('#login-dialog').modal('hide');
                        reloadPreservingBaseUrl();
                    },
                    function(statusCode, statusMessage) {
                        var msg = "Login failed: status code: " + statusCode + " statusMessage: " + statusMessage;
                        toastError(msg);
                    }
            );
        } else {
            ff.login (ffdb_mainViewModel.userName(), ffdb_mainViewModel.password(),
                    function(loggedInUser) {
                        var statusMessage = "Successfully logged in as " + loggedInUser.userName;
                        toast (statusMessage);
                        ffdb_mainViewModel.userName(loggedInUser.userName);
                        ffdb_mainViewModel.loggedInUserName(loggedInUser.userName);

                        ffdb_mainViewModel.reloadMetaData();

                        $('#login-dialog').modal('hide');
                        reloadPreservingBaseUrl();
                    },
                    function(statusCode, statusMessage) {
                        var msg = "Login failed: status code: " + statusCode + " statusMessage: " + statusMessage;
                        toastError(msg);
                    }
            );
        }
    },
    showLogin: function() {

    },

    // TODO: remove?
    register: function() {
        var req = {
            userName: ffdb_mainViewModel.userName(),
            password: ffdb_mainViewModel.password(),
            firstName: ffdb_mainViewModel.firstName(),
            lastName: ffdb_mainViewModel.lastName(),
            email: ffdb_mainViewModel.email()
        };
        ff.register(req,
                function(registeredUser) {
                    var statusMessage = "Successfully registered as " + loggedInUser.userName;
                    toast (statusMessage);
                    ffdb_mainViewModel.userName(registeredUser.userName);
                    ffdb_mainViewModel.loggedInUserName(registeredUser.userName);

                    ffdb_mainViewModel.reloadMetaData();
                },
                function(statusCode, statusMessage) {
                    var msg = "Register failed: status code: " + statusCode + " statusMessage: " + statusMessage;
                    toastError(msg);
                }
        );
    },

    logout: function() {
        ff.logout(
                function(logoutResponse) {
                    var statusMessage = ffdb_mainViewModel.userName() + " successfully logged out";
                    toast (statusMessage);

                    ffdb_mainViewModel.userName("");
                    ffdb_mainViewModel.password("");
                    ffdb_mainViewModel.loggedInUserName("");
                    ffdb_mainViewModel.loggedInUserFirstLastName("Anonymous");

                    ffdb_mainViewModel.reloadMetaData();
                    reloadPreservingBaseUrl();
                },
                function(statusCode, statusMessage) {
                    var msg = "Logout failed: status code: " + statusCode + " statusMessage: " + statusMessage;
                    toastError(msg);
                }
        );
    },

    dismissDetail: function() {
        ffdb_mainViewModel.detailVisible(false);
        ffdb_mainViewModel.tableVisible(true);
        ffdb_mainViewModel.updateQueryHistoryButtons();
    }
};

function reloadPreservingBaseUrl() {
    var newLocation = location.toString().split("?")[0].split("#")[0] + "?baseUrl=" + ff.getBaseUrl();
    window.location = newLocation;
}

function toastError(sMessage) {
    toast(sMessage, true);
}

function toast(sMessage, error, fadeOutDelay) {
    if (fadeOutDelay === undefined)
        fadeOutDelay = 2000;

    if ($('.toast').length <= 0) {
        var container = $(document.createElement("div"));
        container.addClass("toast");
        container.appendTo(document.body);
    }
    var message = $(document.createElement("div"));
    if (error)
        message.addClass("toastErrorMessage");
    else
        message.addClass("toastMessage");
    message.text(sMessage);
    message.appendTo($('.toast'));
    message.fadeIn("slow").delay(fadeOutDelay).fadeOut("slow", function() {
        $(this).remove();
    });
}

