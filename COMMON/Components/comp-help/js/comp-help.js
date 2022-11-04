initCount = 0;
window.CustomElements = {};
window.CustomElements.List = [];

window.COMP_HELP_LOADED = false;
window.COMP_HELP = {};
/* TIFF CODE */
GLOB_HELP = null;
COMP_HELP._readyFn = [];
COMP_HELP.CompReady = function (sel, fn) {
    var Obj = { selector: sel, fn: fn };
    COMP_HELP._readyFn.push(Obj);
    if ($(sel).length > 0 && $(sel).html() != "") {
        fn();
    }
}



COMP_HELP.fnShowProgress = function (selector) {
    selector = selector ? selector : "body";
    var imagePrw = $(document).find(selector);
    if (imagePrw != undefined && imagePrw != null) {
        if (imagePrw.hasOwnProperty("length") || imagePrw.selector)
            imagePrw = imagePrw[0];
    }
    var width = $(imagePrw).width();
    var height = $(imagePrw).height();
    var xModalDiv = $("<div id='scan_modalProgess'><h1 style='position:relative;font-size:13px;top:50%;color:#000;'>Processing your Request...</h1></div>");
    xModalDiv.css({
        'position': 'absolute',
        'top': 0,
        'left': 0,
        'z-index': '999999999999',
        'width': width,
        'height': height,
        'text-align': 'center',
        'vartical-aign': 'middle'
    });
    xModalDiv.remove();
    xModalDiv.appendTo(imagePrw);
}

COMP_HELP.fnRemoveProgress = function () {
    $("#scan_modalProgess").fadeOut("slow");
    setTimeout(function () {
        $("#scan_modalProgess").remove();
    }, 1000);    
}



//search
COMP_HELP.searchGrid = function (gridcomp, param) {
   
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    var rowdata = gridcomp.rowDATA;
    var paramkeys = Object.keys(param);
    var filterData = [];
  
    if (paramkeys.length == 0) {
        filterData = gridcomp.rowDATA;
    }
    else {
        filterData = $(rowdata).filter(function () {
            var isFound = true;
            for (var i = 0; i < paramkeys.length; i++) {
                var filterkey = paramkeys[i];
                var value_Lower = param[paramkeys[i]];
                value_Lower = value_Lower.toLowerCase();

                var filterValue = this[filterkey] || "";
                filterValue = filterValue.toString();
                filterValue = filterValue.toLowerCase();


                if (filterValue.indexOf(value_Lower) == -1)
                    isFound = false;
            }
            return isFound;
        });
    }

    $(gridcomp).find("tbody").empty();
    $(gridcomp).initGrid({
        DataBody: filterData,
        paginationSize: 20,
        isPagination: true,
        isSearch: true
    });
}
//resize
COMP_HELP.colResize = function (gridcomp) {
    return;
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    window.resizeGrid = gridcomp;
    $(window).resize(function () {

        var $table = resizeGrid.querySelector('table.scroll'),
        $bodyCells = $($table.querySelectorAll('thead tr:first-child th')).not(".hidden"),
        //$bodyCells = $($table.querySelectorAll('tbody tr:first-child td')).not(".hidden"),
        colWidth;

        colWidth = $($bodyCells).map(function () {
            return $(this).width();
        }).get();

        var colLEn = colWidth.length;
        var trcount = 0;
        
        $($table.querySelectorAll('tbody.grid-body tr')).children("td").not(".hidden").each(function (i, v) {
            if (trcount == colLEn)
                trcount = 0;
            //$(this).width(colWidth[trcount] - 3);
            $(this).css("width", colWidth[trcount] - 3);
            $(this).css("max-width", colWidth[trcount] - 3);
            //$(v).css("min-width", colWidth[trcount] - 3);
            trcount++;
        });


    }).resize();
}
//goto
COMP_HELP.GoToPage = function (gridcomp, pos) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    pos = $.isNumeric(pos) ? (pos >= 0 ? pos : -1) : -1;
    var pagenumber = pos;
    gridcomp.currentPage = parseInt(pagenumber);
    var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE,
        curPage = pagenumber - 1, maxPageSize = Math.ceil(rowDATA.length / pageLength);
    maxPageSize = maxPageSize == 0 ? 1 : maxPageSize;
    var from = curPage * pageLength;
    var to = pagenumber * pageLength;
    to = to > rowDATA.length ? rowDATA.length : to;
    rowDATA = rowDATA.slice(from, to);
    gridcomp.querySelector("tbody.grid-body").innerHTML = "";
    var rowindex = from;
    $(rowDATA).each(function (indx, elem) {
        COMP_HELP.addNewRow(gridcomp, elem, '', true, rowindex);
        rowindex++;
    });
    //COMP_HELP.colResize(gridcomp);
    // Hide Extra page number - dot-page
    try {
        $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).removeClass("active-page");
        $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).hide();
    }
    catch (e) { }

    $(gridcomp.querySelectorAll(".footer-div ul li")).removeClass("active-page");
    $(gridcomp.querySelectorAll(".footer-div ul li.page-text")).text('Page ' + (gridcomp.currentPage) + ' of ' + maxPageSize);
    var pageLi = $(gridcomp.querySelector(".footer-div ul li[page='" + gridcomp.currentPage + "']"));
    if (pageLi.length > 0) {
        $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).removeClass("active-page");
        $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).hide();
        pageLi.addClass("active-page");
    }
    else {
        gridcomp.querySelector(".footer-div ul li.dot-page-number").classList.add("active-page");
        gridcomp.querySelector(".footer-div ul li.dot-page-number").innerHTML = gridcomp.currentPage;
        $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).show();
    }
    if (gridcomp.currentPage == 1) {
        $(gridcomp.querySelector("[type='P']")).css("cursor", "not-allowed");
    }
    else if (gridcomp.currentPage == maxPageSize) {
        $(gridcomp.querySelector("[type='N']")).css("cursor", "not-allowed");
    }
    COMP_HELP.colResize(gridcomp);
}
//dynamic
COMP_HELP.dynamicSort = function (property) {
    var sortOrder = 1;
    if (property[0] === "-") {
        sortOrder = -1;
        property = property.substr(1);
    }
    return function (a, b) {
        var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
        return result * sortOrder;
    }
};
//sortgrid
COMP_HELP.sortgrid = function (elem) {
    var gridcomp = $(elem).closest("comp-grid");
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    var key = $(elem).attr("key");
    var sorted = $(elem).attr("sorted");
    var sortType = true;
    $(gridcomp.querySelectorAll("[sorted]")).attr("sorted", "");
    if (sorted && sorted.toString() == "ASC") {
        $(elem).attr("sorted", "DES");
        $(gridcomp).find(".grid-up").css("visibility", "hidden");
        $(gridcomp).find(".grid-down").css("visibility", "hidden");
        $(elem).css("visibility", "visible");
        $(elem).find(".grid-up").css("visibility", "hidden");
        $(elem).find(".grid-down").css("visibility", "visible");
        sortType = false;
    }
    else {
        $(elem).attr("sorted", "ASC");
        $(gridcomp).find(".grid-up").css("visibility", "hidden");
        $(gridcomp).find(".grid-down").css("visibility", "hidden");
        $(elem).css("visibility", "visible");
        $(elem).find(".grid-down").css("visibility", "hidden");
        $(elem).find(".grid-up").css("visibility", "visible");
    }
    var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, curPage = gridcomp.currentPage - 1,
    maxPageSize = Math.ceil(rowDATA.length / pageLength);
    if (sortType)
        rowDATA = rowDATA.sort(COMP_HELP.dynamicSort(key));
    else
        rowDATA = rowDATA.sort(COMP_HELP.dynamicSort("-" + key));
    gridcomp.querySelector("tbody.grid-body").innerHTML = "";
    gridcomp.currentPage = 1;
    gridcomp.rowDATA = rowDATA;
    /*for (var i = 0; i < rowDATA.length; i++) {
        rowDATA[i]["rowINDEX"] = i;
        gridcomp.rowDATA.push(rowDATA[i]);
    }
    */
    COMP_HELP.GoToPage(gridcomp, gridcomp.currentPage);
    //COMP_HELP.colResize(gridcomp);
};

COMP_HELP.setRowINDEX = function (gridcomp) {

};
debugger;
var valser=$("comp-help").attr("connect");
if (valser == "bpm") {
    COMP_HELP.SerUrlDomain = getLocalStorage("BpmUrl");
}else{
    COMP_HELP.SerUrlDomain = getLocalStorage("LosUrl");
}

COMP_HELP.clearInput = function (gridcomp) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    $(gridcomp.querySelectorAll(".comp-grid-table thead tr.add-row input")).val("");
    $(gridcomp.querySelectorAll(".comp-grid-table thead tr.add-row input")).attr("pk", "0");
}

COMP_HELP.extend = {
    /*  Sets the given values to the data adding row  */
    getRowProp: function () {

    },
    setHelpValue: function (data, attributes) {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        if (data && typeof data == "object") {
            var Val = data.val;
            var text = data.text;
            $(gridcomp).find("[name='helptext']").attr("val", Val);
            $(gridcomp).find("[name='helptext']").val(text);
        }
        if (attributes && attributes.length > 0) {
            for (var i = 0; i < attributes.length; i++) {
                var attr = attributes[i].attr;
                var val = attributes[i].val;
                $(gridcomp).find("[name='helptext']").attr(attr, val);
            }
        }
    },
    setInput: function (data) {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        //$(gridcomp).clearInput();
        COMP_HELP.clearInput(gridcomp);
        if (data == {} || data == null)
            return;
        var Objkeys = Object.keys(data);
        for (var i = 0; i < Objkeys.length; i++) {
            $(gridcomp.querySelector("tr.add-row input[key='" + Objkeys[i] + "']")).val(data[Objkeys[i]]);
        }
    },
    /*  gets the rowdata of the index position */
    /*  clears the add row */
    clearInput: function () {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        $(gridcomp).find("input").val("");
    },
    /*  initializes the grid with or without data */
    initGrid: function (options) {
      
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        options = options ? options : {};
        initCount++;
        var DataHead = options.DataHead || {},
            DataBody = options.DataBody || [],
            paginationSize = options.paginationSize,
            isPagination = options.isPagination || false,
            scrollHeight = options.scrollHeight || 320,
              isSearch = options.isSearch || false;
        // if (options.DataBody.length > 1000 && options.isPagination == true)    

        DataHead = DataHead || [];
        DataBody = DataBody || [];
        gridcomp.headDATA = DataHead;

        if (!isSearch)
            gridcomp.rowDATA = [];

        try {
            if ($.isNumeric(paginationSize) && paginationSize > 100) { alert("Max PageLength is 100 rows per Page"); }
        } catch (e) { }
        gridcomp.paginationSIZE = $.isNumeric(paginationSize) ? (paginationSize == 0 ? 10 : (paginationSize > 100 ? 100 : paginationSize)) : 10;
        gridcomp.isPagination = isPagination;
        var _pagesize = gridcomp.paginationSIZE;

        if (!isPagination)
            gridcomp.paginationSIZE = DataBody.length;
        
        if (!isSearch) {
            var searchTR = "<tr class='search-tr'>";
            var thead = "<tr class='thead-tr'>";
            var theadAddRow = "";
            var tbody = "<tr class='grid-row'>";
            var EnterImg = "<img class='enter-icon' src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAA3NCSVQICAjb4U/gAAAACXBIWXMAAAB0AAAAdAExheWBAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAEJQTFRF////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhihLswAAABV0Uk5TAAcRMEhMXmBiZWp4g4qYq83U5/f+Viz5HgAAAFRJREFUGJWFj9sOgCAMQysbXifidP//qz4IhECM5/EkbVo4USuoOEhkKnAUKKOCFUa1IPsW29gIf81JHOHlvD1AhjU0IlMimX1Kpcvwt6Ob3p1r7z9ugQZkpy4T1gAAAABJRU5ErkJggg==' />";
            var dataheading = [];
            if (DataBody.length > 0)
                dataheading = Object.keys(DataBody[0]);
            for (var i = 0; i < dataheading.length; i++) {
                var key = dataheading[i];
                var key_Lower = dataheading[i].toLowerCase();

                var classname = (key_Lower.indexOf("pk") == key_Lower.length - 2 || key_Lower.indexOf("hdn") == 0 || key_Lower == "rowindex") ? "hidden" : "";

                thead += "<th class='" + classname + "'  key='" + key + "'> " +
                            " <div style='display:none;' title='Sort rows' sorted='' key='" + key + "' onclick='COMP_HELP.sortgrid(this);' class='grid-sortkey'><span class='grid-up'>&#9650</span><span class='grid-down'>&#9660</span></div> " +
                            "<p title='" + key + "' class='lbl'>" + key + "</p>" +
                            //" <span title='search' class='grid-search'> &#128270;</span> " +
                            "</th>";
                tbody += "<td class='" + classname + "' key='" + key + "'></td>";
                searchTR += "<th class='" + classname + "'><input class='searchbox' type='text' placeholder='search..' key='" + key + "'/></th>";//th to td change by cs
            }


            //thead += "</tr><tr class='add-row'>" + theadAddRow + "</tr>";
            thead += "</tr>" + searchTR + "</tr>";
            tbody += "</tr>";

            try {
                $(gridcomp).prop("rowHTML", tbody);
                gridcomp.rowHTML = tbody;
                $(gridcomp).prop("searchTR", searchTR);
            } catch (e) { }

            gridcomp.querySelector("table.comp-grid-table thead").innerHTML = thead;
        }

        for (var j = 0; j < DataBody.length ; j++) {
            DataBody[j]["rowINDEX"] = j;
            if (j < _pagesize) {
                COMP_HELP.addNewRow(gridcomp, DataBody[j]);
            }
            if (!isSearch) {
                gridcomp.rowDATA.push(DataBody[j]);
            }
        }
        //needed
        COMP_HELP.colResize(gridcomp);
        if (!isPagination)
            gridcomp.querySelector(".footer-div").remove();
        else
            COMP_HELP.buildPagination(gridcomp);
        //$(gridcomp.querySelector("table.comp-grid-table tbody.grid-body")).css("height", scrollHeight);
        gridcomp.isInitiaziled = true;
        if (!isSearch)
            $($(gridcomp).find("th:not(.hidden) input.searchbox")[0]).focus();
    },
    /* Loads particular data- for pagination */
    loadPageData: function (data, needClear) {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        if (needClear)
            gridcomp.querySelector("tbody.grid-body").innerHTML = "";
        $(data).each(function (indx, elem) {
            COMP_HELP.addNewRow(gridcomp, elem, '', true);
        });
        COMP_HELP.colResize(gridcomp);
    },
    /*  edit the rowdata of the index position */
    /*  adds a new row in the given position */
    addNewRow: function (data, pos, isPagination) {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        pos = $.isNumeric(pos) ? (pos >= 0 ? pos : -1) : -1;
        var editrow = $(gridcomp).find("tbody.grid-body tr.edit-row");
        var editLength = editrow.length;
        var rowHTML = editLength > 0 ? editrow : $(gridcomp.rowHTML);
        var editRowIndex = $(editrow).attr("rowindex");
        var keyArr = Object.keys(data);
        rowHTML.attr("rowINDEX", gridcomp.rowDATA.length);
        for (var i = 0; i < keyArr.length; i++) {
            rowHTML.find("[key=" + keyArr[i] + "]").text(data[keyArr[i]]);
            rowHTML.find("[key=" + keyArr[i] + "]").attr("title", data[keyArr[i]]);
            if (editLength > 0)
                gridcomp.rowDATA[editRowIndex][keyArr[i]] = data[keyArr[i]];
        }
        if (editLength == 0) {
            if (!isPagination)
                gridcomp.rowDATA.push(data);
            if (pos == -1)
                $(gridcomp).find("tbody.grid-body").append(rowHTML);
            else
                $(gridcomp).find("tbody.grid-body tr:nth-child(" + (pos + 1) + ")").before(rowHTML);
        }
        else {
            $(editrow).removeClass("active-row");
            $(editrow).removeClass("edit-row");
        }
        //COMP_HELP.colResize(gridcomp);
    },
    nextPage: function () {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, curPage = gridcomp.currentPage,
            maxPageSize = Math.ceil(rowDATA.length / pageLength);
        maxPageSize = maxPageSize == 0 ? 1 : maxPageSize;
        if (gridcomp.currentPage < maxPageSize) {
            var from = curPage * pageLength;
            var to = (curPage * pageLength) + pageLength;
            to = to > rowDATA.length ? rowDATA.length : to;
            rowDATA = rowDATA.slice(from, to);
            gridcomp.querySelector("tbody.grid-body").innerHTML = "";
            var rowindex = from;
            $(rowDATA).each(function (indx, elem) {
                COMP_HELP.addNewRow(gridcomp, elem, '', true, rowindex);
                rowindex++;
            });
            //COMP_HELP.colResize(gridcomp);
            if (gridcomp.currentPage < maxPageSize)
                gridcomp.currentPage++;
            $(gridcomp.querySelectorAll(".footer-div ul li")).removeClass("active-page");
            $(gridcomp.querySelectorAll(".footer-div ul li.page-text")).text('Page ' + gridcomp.currentPage + ' of ' + maxPageSize);

            if ($(gridcomp.querySelector(".footer-div ul li[page='" + gridcomp.currentPage + "']")).length > 0) {
                $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).removeClass("active-page");
                $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).hide();
                gridcomp.querySelector(".footer-div ul li[page='" + gridcomp.currentPage + "']").classList.add("active-page");
            }
            else {
                gridcomp.querySelector(".footer-div ul li.dot-page-number").classList.add("active-page");
                gridcomp.querySelector(".footer-div ul li.dot-page-number").innerHTML = gridcomp.currentPage;
                $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).show();
            }
            if (gridcomp.currentPage == maxPageSize) {
                $(gridcomp.querySelector("[type='N']")).css("cursor", "not-allowed");
            }
        }
    },
    prevPage: function () {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, curPage = gridcomp.currentPage,
            maxPageSize = Math.ceil(rowDATA.length / pageLength);
        maxPageSize = maxPageSize == 0 ? 1 : maxPageSize;
        if (gridcomp.currentPage != 1) {
            var from = curPage * pageLength - 2 * pageLength;
            var to = curPage * pageLength - pageLength;
            to = to > rowDATA.length ? rowDATA.length : to;
            rowDATA = rowDATA.slice(from, to);
            gridcomp.querySelector("tbody.grid-body").innerHTML = "";
            var rowindex = from;
            $(rowDATA).each(function (indx, elem) {
                COMP_HELP.addNewRow(gridcomp, elem, '', true, rowindex);
                rowindex++;
            });
            //COMP_HELP.colResize(gridcomp);
            $(gridcomp.querySelectorAll(".footer-div ul li")).removeClass("active-page");
            $(gridcomp.querySelectorAll(".footer-div ul li.page-text")).text('Page ' + (gridcomp.currentPage - 1) + ' of ' + maxPageSize);
            if (gridcomp.currentPage > 1)
                gridcomp.currentPage--;
            if ($(gridcomp.querySelector(".footer-div ul li[page='" + gridcomp.currentPage + "']")).length > 0) {
                $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).removeClass("active-page");
                $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).hide();
                gridcomp.querySelector(".footer-div ul li[page='" + gridcomp.currentPage + "']").classList.add("active-page");
            }
            else {
                gridcomp.querySelector(".footer-div ul li.dot-page-number").classList.add("active-page");
                gridcomp.querySelector(".footer-div ul li.dot-page-number").innerHTML = gridcomp.currentPage;
                $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).show();
            }
            if (gridcomp.currentPage == 1) {
                $(gridcomp.querySelector("[type='P']")).css("cursor", "not-allowed");
            }
        }
    },
    clearGrid: function () {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        $(gridcomp).find("thead").empty();
        $(gridcomp).find("tbody").empty();
    }
};


$.fn.extend(COMP_HELP.extend);



COMP_HELP.CallBack = function (serviceFor, Obj, Param1, Param2) {
  
    if (!Obj.status)
        return;

    if (serviceFor == "HELP") {     
        GLOB_HELP = Param2;
        var bodyData = JSON.parse(Obj.result);        
        $(Param2).find(".popupdiv").show();
        bodyData = bodyData ? bodyData : [];
        if (!bodyData || bodyData.length == 0)
        {
            $(Param2).find(".grid-head").html("<tr><th>No help available for your search.</th></tr>");

        } else {
            $(Param2).clearGrid();
            $(Param2).initGrid({
                DataHead: [],
                DataBody: bodyData,
                paginationSize: 20,
                isPagination: true
            });
        }
        
        //COMP_HELP.colResize(Param2);
    }
};

COMP_HELP.CallWebService = function (serviceFor, prcObject, callback, extParam1, extParam2) {
    COMP_HELP.fnShowProgress();
    debugger;
    var jsonData = null;
    var SerUrl = "";
    if (typeof prcObject == "string")
        prcObject = JSON.parse(prcObject);
    if (extParam1 == "TEXT") {
        jsonData = prcObject
        SerUrl = COMP_HELP.SerUrlDomain + "FileManager_Handler.ashx";
    }
    else if (extParam1 == "MULTI") {
        jsonData = JSON.stringify(prcObject);
        SerUrl = COMP_HELP.SerUrlDomain + "RestServiceSvc.svc/fnDataAccessService";
    }
    else {
        jsonData = JSON.stringify(prcObject);
        SerUrl = COMP_HELP.SerUrlDomain + "RestServiceSvc.svc/fnDataAccessService";
    }
    $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        url: SerUrl,
        data: jsonData,
        processData: true,
        async: true,
        success: function (data) {
            COMP_HELP.fnRemoveProgress();
            var result = JSON.parse(data);
            if (result.status == false) {
                alert("Error Processing request")
                console.log(result.error);
                return;
            }
            callback(serviceFor, result, extParam1, extParam2);
        },
        error: function (data, q, t) {
            COMP_HELP.fnRemoveProgress();
            console.log('Error: ', data);
        }
    });
};

COMP_HELP.addNewRow = function (gridcomp, data, pos, isPagination, SearchRowINDEX) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    var rowHTML = $(gridcomp.rowHTML);
    var CurPageNum = gridcomp.currentPage - 1;
    var PageSize = gridcomp.paginationSIZE;
    var keyArr = Object.keys(data);

    rowHTML.attr("rowjson", JSON.stringify(data));
    for (var i = 0; i < keyArr.length; i++) {
        rowHTML.find("[key=" + keyArr[i] + "]").text(data[keyArr[i]]);
        rowHTML.find("[key=" + keyArr[i] + "]").attr("title", data[keyArr[i]]);
    }

    $(gridcomp.querySelector("tbody.grid-body")).append(rowHTML);

    /*
    if (gridcomp.isPagination)
        COMP_HELP.buildPagination(gridcomp);
    $(gridcomp.querySelector("tbody.grid-body")).scrollTop($(gridcomp.querySelector("tbody.grid-body"))[0].scrollHeight);
    COMP_HELP.clearInput(gridcomp);
    */
}





COMP_HELP.setRowINDEX = function (gridcomp) {

};

/*COMP_HELP.searchGrid = function (gridcomp, searchkey, searchval) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    $(gridcomp.querySelector("tbody.grid-body")).empty();
    var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, curPage = gridcomp.currentPage - 1,
    maxPageSize = Math.ceil(rowDATA.length / pageLength);
    var from = curPage * pageLength;
    var to = (curPage * pageLength) + pageLength;
    to = to > rowDATA.length ? rowDATA.length : to;
    rowDATA = rowDATA.slice(from, to);
    var rowDATAindex = from;
    searchval = searchval.toLowerCase();
    $(rowDATA).each(function (e) {
        var valText = this[searchkey].toLowerCase();
        if (valText.indexOf(searchval) >= 0)
            COMP_HELP.addNewRow(gridcomp, this, '', true, rowDATAindex);
        rowDATAindex++;
    });
    COMP_HELP.colResize(gridcomp);
}
*/
COMP_HELP.buildPagination = function (gridcomp) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, curPage = gridcomp.currentPage,
    maxPageSize = Math.ceil(rowDATA.length / pageLength);
    maxPageSize = maxPageSize == 0 ? 1 : maxPageSize;
    var pagination = '<ul class="pagination"><li class="page-text">Page 1 of ' + maxPageSize + '</li><li class="page-nav" type="P">Prev</li>';
    var needDots = false;
    var dotAdded = false;
    if (maxPageSize > 10)
        needDots = true;

    for (var i = 0; i < maxPageSize; i++) {
        var actv = "";
        if (i == 0)
            actv = " active-page";
        if (i > 4 && needDots && !dotAdded) {
            pagination += '<li no="1" class="dots">..</li><li style="display:none;" class="page-num dot-page-number"></li><li no="2" class="dots">..</li>';
            dotAdded = true;
            i = maxPageSize - 3;
            continue;
        }
        pagination += '<li page="' + (i + 1) + '" class="page-num' + actv + '">' + (i + 1) + '</li>';
    }
    pagination += '<li class="page-nav" type="N">Next</li><li class="page-goto" type="G">Go to <input type="text" class="gridgoto" /></li></ul>';
    gridcomp.querySelector(".footer-div").innerHTML = pagination;
    

    $(gridcomp.querySelectorAll("li.page-num")).not("li.dot-page-number").click(function () {
        var pagenumber = $(this).attr("page");
        gridcomp.currentPage = parseInt(pagenumber);
        var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE,
            curPage = pagenumber - 1, maxPageSize = Math.ceil(rowDATA.length / pageLength);
        maxPageSize = maxPageSize == 0 ? 1 : maxPageSize;
        var from = curPage * pageLength;
        var to = pagenumber * pageLength;
        to = to > rowDATA.length ? rowDATA.length : to;
        rowDATA = rowDATA.slice(from, to);
        gridcomp.querySelector("tbody.grid-body").innerHTML = "";
        var rowindex = from;
        $(rowDATA).each(function (indx, elem) {
            COMP_HELP.addNewRow(gridcomp, elem, '', true, rowindex);
            rowindex++;
        });

        //COMP_HELP.colResize(gridcomp);

        // Hide Extra page number - dot-page
        try {
            $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).removeClass("active-page");
            $(gridcomp.querySelector(".footer-div ul li.dot-page-number")).hide();
        }
        catch (e) { }

        $(gridcomp.querySelectorAll(".footer-div ul li")).removeClass("active-page");
        $(gridcomp.querySelectorAll(".footer-div ul li.page-text")).text('Page ' + (gridcomp.currentPage) + ' of ' + maxPageSize);
        gridcomp.querySelector(".footer-div ul li[page='" + gridcomp.currentPage + "']").classList.add("active-page");
        if (gridcomp.currentPage == 1) {
            $(gridcomp.querySelector("[type='P']")).css("cursor", "not-allowed");
        }
        else if (gridcomp.currentPage == maxPageSize) {
            $(gridcomp.querySelector("[type='N']")).css("cursor", "not-allowed");
        }
        COMP_HELP.colResize(gridcomp);

    });



    $(gridcomp.querySelectorAll(".footer-div ul li.page-nav")).click(function (e) {
        var type = $(this).attr("type");
        var gridcomp = $(this).closest("comp-help");
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        if (type == "N") {
            $(gridcomp).nextPage();
        }
        else if (type == "P") {
            $(gridcomp).prevPage();
        }
        COMP_HELP.colResize(gridcomp);
    });


    $(gridcomp.querySelectorAll(".footer-div ul li input.gridgoto")).keydown(function (e) {
        e = e || window.event;
        var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
        var key = e.key ? e.key : "X";
        if (!$.isNumeric(key) && keyCode > 31 && (keyCode < 48 || keyCode > 57)) {
            return false;
        }
        var gridcomp = $(this).closest("comp-help");
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        if (keyCode == 13) {
            var Txtnumber = parseInt($(this).val());
            if ($.isNumeric(Txtnumber)) {
                var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, maxPageSize = Math.ceil(rowDATA.length / pageLength);
                if (Txtnumber > 0 && Txtnumber <= maxPageSize)
                    COMP_HELP.GoToPage(gridcomp, Txtnumber);
            }
        }

        //COMP_HELP.colResize(gridcomp);
        return true;
    });

    $(gridcomp.querySelectorAll("li.page-nav")).mouseover(function () {

        var pagenumber = $(gridcomp.querySelector("ul.pagination li.active-page")).attr("page");
        var maxpage = Math.ceil(gridcomp.rowDATA.length / gridcomp.paginationSIZE);
        maxpage = maxpage == 0 ? 1 : maxpage;
        if (pagenumber == 1) {
            if ($(this).is("[type='P']"))
                $(this).css("cursor", "not-allowed");
            else
                $(this).css("cursor", "pointer");
            if (pagenumber == maxpage) { $(this).css("cursor", "not-allowed"); }
        }
        else if (pagenumber == maxpage) {
            if ($(this).is("[type='N']"))
                $(this).css("cursor", "not-allowed");
            else
                $(this).css("cursor", "pointer");
        }
        else {
            $(this).css("cursor", "pointer");
        }
    });
}

$.fn.extend(COMP_HELP.extend);



var createComponent_help = function (TagName, HtmlSrc) {

    var ElementProto = Object.create(HTMLElement.prototype);

    /* DEFINITIONS */
    ElementProto.readonly = false;
    ElementProto.rowHTML = "";
    ElementProto.rowDATA = [];
    ElementProto.headDATA = [];
    ElementProto.isInitiaziled = false;
    ElementProto.isPagination = false;
    ElementProto.paginationSIZE = 10;
    ElementProto.currentPage = 1;

    ElementProto.createdCallback = function () {
        /* Fired when the Element is created */
    }
    ElementProto.attachedCallback = function () {
        /* Fired when the Element is attached to the document */

        /* Changing the content & Events */

        //var GridShadow = this.createShadowRoot();

        var GridShadow = this;
        var componentWidth = this.getAttribute("width") || this.width || "100%";
        var componentHeight = this.getAttribute("height") || this.height || "100%";
        var isReadOnly = this.getAttribute("readonly") || this["readonly"];
        componentWidth = componentWidth == 0 ? "100%" : componentWidth;
        componentHeight = componentHeight == 0 ? "100%" : componentHeight;
        var componentID = this.getAttribute("id") || this.id || "";
        var Ishidden = this.getAttribute("comp-hidden") || this["comp-hidden"] || "";
        Ishidden = Ishidden.toString().toLowerCase();

        var htmltoAppend = "";

        if (HtmlSrc && HtmlSrc != "") {
            var textContent = document.querySelector("#" + HtmlSrc).import;
            htmltoAppend = textContent.querySelector("custom-component").innerHTML;
        } else {
            htmltoAppend = document.getElementById("HtmlSrc").innerHTML;
        }

        GridShadow.innerHTML = htmltoAppend;


        /* OPTIONS - EVENTS */
        if (Ishidden == "true") {
            $(this).find(".helpbox-container").hide();
        }


        var helptextBox = $(GridShadow).find("input[name='helptext']");        
        var helpEnterIcon = $(GridShadow).find(".enter-icon");


        if (isReadOnly) {
            $(helptextBox).attr("readonly", "readonly");
            $(helpEnterIcon).css("pointer-events", "none");
        }

        var iconclose = $(GridShadow).find(".icon-close");

        $(iconclose).click(function () {
            var gridcomp = $(this).closest("comp-help");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            $(gridcomp).find("tbody.grid-body").empty();
            $(gridcomp).find("input[name='helptext']").focus();
        });


        var procedure = $(GridShadow).attr("prcname");
        var helpbranch = '';

        //$(helptextBox).focusout(function () {
        //    var textval = $(this).attr("textval") || "";
        //    var enteredText = $(this).val();
        //    if (textval != enteredText) {
        //        $(this).val(textval);
        //    }            
        //});
        

        $(helptextBox).dblclick(function () {
            var gridcomp = $(this).closest("comp-help");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            var isReadOnly = gridcomp.getAttribute("readonly") || gridcomp.readonly;            
            if (isReadOnly)
                return false;

            var e = $.Event("keyup");
            e.which = 13;            
            $(this).trigger(e);
        });

        $(helpEnterIcon).click(function () {
            var gridcomp = $(this).closest("comp-help");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            var isReadOnly = gridcomp.getAttribute("readonly") || gridcomp.readonly;            
            if (isReadOnly)
                return false;
            var e = $.Event("keyup");
            e.which = 13;
            $(this).siblings("input[name='helptext']").trigger(e);
        });        

        $(helptextBox).keyup(function (e) {
                     
            var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
            if (keyCode != 13)
                return;           
            var gridcomp = $(this).closest("comp-help");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }

            var isReadOnly = gridcomp.getAttribute("readonly") || gridcomp.readonly;
            if (isReadOnly)
                return false;

            if ($(gridcomp).is("[helpfk]")) {
                if ($(gridcomp).attr("helpfk") != "0") {
                    helpbranch = $(gridcomp).attr("helpfk");
                }
                else {
                    helpbranch = '';
                }
            }
            var extraparamval = gridcomp.getAttribute("extraparam") || "";

            var valser = $(gridcomp).attr("connect");

            if (valser == "bpm") {
                COMP_HELP.SerUrlDomain = getLocalStorage("BpmUrl");
            } else {
                COMP_HELP.SerUrlDomain = getLocalStorage("LosUrl");
            }

            //$(gridcomp).clearGrid();
            $(gridcomp).find(".popupdiv").show();

            if (extraparamval.length > 0) {
                var searchval = $(helptextBox).val();
                searchval = searchval ? searchval : "";
                searchval = searchval.trim();
                var Obj = { ProcedureName: procedure, Type: "SP", Parameters: [searchval, helpbranch, extraparamval] };
                COMP_HELP.CallWebService("HELP", Obj, COMP_HELP.CallBack, "MULTI", gridcomp);
            }
            else {
                var searchval = $(helptextBox).val();
                searchval = searchval ? searchval : "";
                searchval = searchval.trim();
                var Obj = { ProcedureName: procedure, Type: "SP", Parameters: [searchval, helpbranch] };
                COMP_HELP.CallWebService("HELP", Obj, COMP_HELP.CallBack, "MULTI", gridcomp);
            }
        });


        if (!COMP_HELP_LOADED) {

            $(document).on("click", "comp-help table tbody.grid-body tr.grid-row", function () {
              
                var gridcomp = $(this).closest("comp-help");
                if (gridcomp != undefined && gridcomp != null) {
                    if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                        gridcomp = gridcomp[0];
                }
              

                var txtcol = $(gridcomp).attr("txtcol");
                var valcol = $(gridcomp).attr("valcol");
                var Name = $(this).find("td[key='" + txtcol + "']").attr("title");
                var pk = $(this).find("td[key='" + valcol + "']").attr("title");
                $(gridcomp).find("input[name='helptext']").val(Name);
                $(gridcomp).find("input[name='helptext']").attr("val", pk);
                $(gridcomp).find("input[name='helptext']").attr("textval", Name);
                $(gridcomp).find(".popupdiv").hide();
                $(gridcomp).find("tbody").empty();

                var fnname = $(gridcomp).attr("onrowclick");
                try {
                    if (window[fnname]) {
                        var rowjson = $(this).attr("rowjson");
                        window[fnname](JSON.parse(rowjson), gridcomp);
                    }
                }
                catch (e) { }
            });


            $(document).on("keyup", "comp-help table tr th input.searchbox", function (e) {
                var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
                if (keyCode == 38 || keyCode == 40 || keyCode == 13 || keyCode == 37 || keyCode == 39)
                    return;
                $(gridcomp).find("input.searchbox").focusout();
                var obj = {};
                var gridcomp = $(this).closest("comp-help");
                if (gridcomp != undefined && gridcomp != null) {
                    if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                        gridcomp = gridcomp[0];
                }
                $(gridcomp).find("input.searchbox").each(function () {
                    var key = $(this).attr("key");
                    var value = $(this).val();
                    value = value ? value : "";
                    if (value != "")
                        obj[key] = value;
                });                
                COMP_HELP.searchGrid(gridcomp, obj);
            });

            $(document).keyup(function (e) {
                e = e || window.event;
                var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
                if (!GLOB_HELP)
                    return;
                var gridcomp = GLOB_HELP;
                var gridTableHead = $(gridcomp).find(".comp-grid-table thead");
                var rows = gridTableHead.find("tr").length;
                if (rows > 0) {
                    switch (keyCode) {                      
                        case 27:
                            e.preventDefault();
                            try { $(gridcomp).find(".icon-close").click(); } catch (e) { }
                            break;
                        default:
                            return;
                    }
                }
            });
           
            $(document).keydown(function (e) {
                e = e || window.event;
                var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
                if (!GLOB_HELP)
                    return;
                var gridcomp = GLOB_HELP;
                var gridTableBody = $(gridcomp).find(".comp-grid-table tbody.grid-body");
                var rows = gridTableBody.find("tr").length;
                if (rows > 0) {
                    switch (keyCode) {
                        case 13: // enter
                            e.preventDefault();
                            var activeRow = $(gridTableBody).find("tr.active-row");
                            $(activeRow).click();
                            break;
                        case 38: // up
                            e.preventDefault();
                            //$(gridcomp).find("input.searchbox").focusout();
                            var trList = $(gridTableBody).find("tr");
                            var activeIndex = $(gridTableBody).find("tr.active-row").index();
                            var pos = activeIndex >= 0 ? activeIndex : -1;
                            $(trList).removeClass("active-row");
                            var activerow = null;
                            var w = $(gridcomp).find(".grid-div");
                            if (pos != -1 && pos != 0) {
                                activerow = $(trList[pos - 1]);
                                $(trList[pos - 1]).addClass("active-row");
                            }
                            else if (pos == 0 || pos == -1) {
                                activerow = $(trList[trList.length - 1]);
                                $(trList[trList.length - 1]).addClass("active-row");
                            }
                            if (activerow)
                                activerow[0].scrollIntoView(true);
                            if (pos < 6 && pos != 0)
                                $(gridcomp).find(".comp-grid-table tr.thead-tr")[0].scrollIntoView(true);
                            break;
                        case 40: // down
                            e.preventDefault();
                            //$(gridcomp).find("input.searchbox").focusout();
                            var trList = $(gridTableBody).find("tr");
                            var activeIndex = $(gridTableBody).find("tr.active-row").index();
                            //activeIndex = activeIndex == -1 ? 0 : activeIndex;
                            var pos = activeIndex;
                            $(trList).removeClass("active-row");
                            var activerow = null;
                            var w = $(gridcomp).find(".grid-div");
                            if (pos != -1 && trList.length > pos + 1) {
                                activerow = $(trList[pos + 1]);
                                $(trList[pos + 1]).addClass("active-row");
                            }
                            else if (trList.length <= pos + 1 || pos == -1) {
                                activerow = $(trList[0]);
                                $(trList[0]).addClass("active-row");
                            }
                            if (activerow)
                                activerow[0].scrollIntoView(true);
                            if (pos < 6 || pos == trList.length - 1)
                                $(gridcomp).find(".comp-grid-table tr.thead-tr")[0].scrollIntoView(true);
                            break;
                        case 37: // left
                            e.preventDefault();
                            $(gridcomp).find(".searchbox").focusout();
                            $(gridcomp).find(".page-nav[type='P']").click();
                            $($(gridcomp).find("th:not(.hidden) input.searchbox")[0]).focus();
                            break;
                        case 39: // right
                            e.preventDefault();
                            $(gridcomp).find(".searchbox").focusout();
                            $(gridcomp).find(".page-nav[type='N']").click();
                            $($(gridcomp).find("th:not(.hidden) input.searchbox")[0]).focus();
                            break;
                        default:
                            return;
                    }
                }
            });


        }

        COMP_HELP_LOADED = true;

        /* OPTIONS - EVENTS */

        /* RENDER - TYPE */

        /* RENDER - TYPE */


        /* APLLY STYLES */

    }
    ElementProto.detachedCallback = function () {
        /* Fired when the Element is removed */
    }
    ElementProto.attributeChangedCallback = function (attrName, oldValue, newValue) {
        //console.log(attrName + "=" + oldValue + "=" + newValue);
        if (attrName == "readonly") {
            var isReadOnly = this.getAttribute("readonly") || this.readonly;

            var helptextBox = $(this).find("input[name='helptext']");
            var helpEnterIcon = $(this).find(".enter-icon");

            if (isReadOnly) {
                $(helptextBox).attr("readonly", "readonly");
                $(helpEnterIcon).css("pointer-events", "none");
            } else {
                    $(helptextBox).removeAttr("readonly");
                    $(helpEnterIcon).css("pointer-events", "auto");
            }
        }
    }

    ElementProto.html = function () {
        return this.innerHTML;
    }

    /*  Register our tag and its properties as an element in the document. 
       So that document will understand the tag and parse it as we designed    */
    var MyElement = document.registerElement(TagName, { prototype: ElementProto });

    /* custom elements object */

    if (window.CustomElements != null && window.CustomElements != undefined) {
        var len = window.CustomElements.List.length;
        window.CustomElements.List[len] = TagName;
    }
    else {
        window.CustomElements = {};
        window.CustomElements.List = [];
        window.CustomElements.List[0] = TagName;

        window.CustomElements.find = function (tagNm) {
            if (window.CustomElements && window.CustomElements.List && window.CustomElements.List.length > 0) {
                var arr = window.CustomElements.List.toString().split(",");
                return arr.indexOf(tagNm.toLowerCase()) !== -1;
            }
            else {
                return false;
            }
        }
    }
    /* custom elements object */


};

createComponent_help("comp-help", "help");