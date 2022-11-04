initCount = 0;
window.CustomElements = {};
window.CustomElements.List = [];

window.COMP_GRID = {};
/* TIFF CODE */

COMP_GRID._readyFn = [];
COMP_GRID.CompReady = function (sel, fn) {
    var Obj = { selector: sel, fn: fn };
    COMP_GRID._readyFn.push(Obj);
    if ($(sel).length > 0 && $(sel).html() != "") {
        fn();
    }
}


COMP_GRID.SerUrlDomain = "http://svschndt1419.svsglobal.com/TEMP_HOST_RS/";

COMP_GRID.clearInput = function (gridcomp) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    $(gridcomp.querySelectorAll(".comp-grid-table thead tr.add-row input")).val("");
    $(gridcomp.querySelectorAll(".comp-grid-table thead tr.add-row input")).attr("pk", "0");
}
COMP_GRID.CallBack = function (serviceFor, Obj, Param1, Param2) {
    if (!Obj.status)
        return;

    if (serviceFor == "HELP") {
        var data = JSON.parse(Obj.result);
        if (data == null || data.length == 0)
            return;
        var helpdiv = $("<div class='help-div'><table class='help-table'><thead></thead><tbody></tbody></table></div>");
        var attrToAppned = $(Param2[0]).attr("key");
        $(Param2[0]).attr("placeholder", "");
        var HeadData = Param2[1];
        var IsPkNeeded = HeadData.isPkValue || false;
        var keys = Object.keys(data[0]);
        var tr = "";
        var thd = "<tr class='helphead'>";
        for (var i = 0; i < data.length; i++) {
            tr = "";
            var selVal = data[i][attrToAppned] || "";
            selVal = selVal == "" ? attrToAppned + " - Given key is wrong" : selVal;
            var Pkvalue = 0;
            for (var j = 0; j < keys.length; j++) {
                if (keys[j].toUpperCase() != "PK") {
                    if (i == 0)
                    { thd += "<th>" + keys[j] + "</th>"; }
                    tr += "<td>" + data[i][keys[j]] + "</td>";
                }
                else { Pkvalue = data[i][keys[j]] || 0; }
            }
            if (!IsPkNeeded)
                Pkvalue = 0;
            tr = "<tr PK='" + Pkvalue + "' class='helprow' val='" + selVal + "'>" + tr + "</tr>";
            $(helpdiv).find("table tbody").append(tr);
        }
        $(helpdiv).find("table thead").append(thd + "</tr>");
        $(Param2[0]).after(helpdiv);
        //$(Param2).parent().append(helpdiv);
        helpdiv = helpdiv[0];
        var $table = helpdiv.querySelector('table'),
       $bodyCells = $table.querySelector('thead tr:first-child').children,
       colWidth;
        $(window).resize(function () {
            colWidth = $($bodyCells).map(function () {
                return $(this).width();
            }).get();

            var colLEn = colWidth.length;
            var trcount = 0;

            $($table.querySelectorAll('tbody tr')).children("td").each(function (i, v) {
                if (trcount == colLEn)
                    trcount = 0;
                var CurWidth = colWidth[trcount];
                if (CurWidth < 50)
                { CurWidth = 50; }
                else
                { CurWidth = colWidth[trcount]; }
                $(this).width(CurWidth - 3);
                $(this).css("max-width", CurWidth - 3);
                $($bodyCells[trcount]).width(CurWidth - 3);
                trcount++;
            });
        }).resize();
        
        $(helpdiv).find("table tr").click(function () {
            var val = $(this).attr("val");
            var Pk = $(this).attr("PK");            
            $(Param2[0]).val(val);
            $(Param2[0]).attr("PK", Pk);
            $(helpdiv).remove();
        });
    }
};

COMP_GRID.CallWebService = function (serviceFor, prcObject, callback, extParam1, extParam2) {
    var jsonData = null;
    var SerUrl = "";
    if (typeof prcObject == "string")
        prcObject = JSON.parse(prcObject);
    if (extParam1 == "TEXT") {
        jsonData = prcObject
        SerUrl = COMP_GRID.SerUrlDomain + "FileManager_Handler.ashx";
    }
    else if (extParam1 == "MULTI") {
        jsonData = JSON.stringify(prcObject);
        SerUrl = COMP_GRID.SerUrlDomain + "RestServiceSvc.svc/fnDataAccessService";
    }
    else {
        jsonData = JSON.stringify(prcObject);
        SerUrl = COMP_GRID.SerUrlDomain + "RestServiceSvc.svc/fnDataAccessService";
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
            var result = JSON.parse(data);
            if (result.status == false) {
                alert("Error Processing Request!!");
                console.log(result.error);
                return;
            }
            callback(serviceFor, result, extParam1, extParam2);
        },
        error: function (data, q, t) {
            console.log('Error: ', data);
        }
    });
};

COMP_GRID.addNewRow = function (gridcomp, data, pos, isPagination,SearchRowINDEX) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    pos = $.isNumeric(pos) ? (pos >= 0 ? pos : -1) : -1;
    var editrow = gridcomp.querySelectorAll("tbody.grid-body tr.edit-row");
    var editLength = editrow.length;
    var rowHTML = editLength > 0 ? $(editrow) : $(gridcomp.rowHTML);
    var CurPageNum = gridcomp.currentPage - 1;
    var PageSize = gridcomp.paginationSIZE;
    var editRowIndex = $(editrow).attr("rowindex");

    var keyArr = Object.keys(data);
    var Editrowindex = rowHTML.attr("rowINDEX");
    Editrowindex = Editrowindex ? Editrowindex : "";
    if (Editrowindex == "")
        rowHTML.attr("rowINDEX", gridcomp.rowDATA.length);
    if ($.isNumeric(SearchRowINDEX))
        rowHTML.attr("rowINDEX", SearchRowINDEX);
    for (var i = 0; i < keyArr.length; i++) {
        var rowPk = data[keyArr[i] + "_PK"];
        if (rowPk && rowPk != "0")
        { rowHTML.find("[key=" + keyArr[i] + "]").attr("PK", rowPk); }
        rowHTML.find("[key=" + keyArr[i] + "]").text(data[keyArr[i]]);
        rowHTML.find("[key=" + keyArr[i] + "]").attr("title", data[keyArr[i]]);
        if (editLength > 0)
            gridcomp.rowDATA[editRowIndex][keyArr[i]] = data[keyArr[i]];
    }
    if (editLength == 0) {
        if (!isPagination) {
            gridcomp.rowDATA.push(data);
        }
        if (pos == -1)
        {
            $(gridcomp.querySelector("tbody.grid-body")).append(rowHTML);
            if (gridcomp.isPagination)
                COMP_GRID.buildPagination(gridcomp);
            if (gridcomp.isInitiaziled && !isPagination && gridcomp.isPagination) {
                var GotPageNo = Math.ceil(gridcomp.rowDATA.length / gridcomp.paginationSIZE);
                GotPageNo = GotPageNo == 0 ? 1 : GotPageNo;
                COMP_GRID.GoToPage(gridcomp, GotPageNo);
            }
            else {
                if (gridcomp.isInitiaziled)
                    $(gridcomp.querySelector("tbody.grid-body")).scrollTop($(gridcomp.querySelector("tbody.grid-body"))[0].scrollHeight);
            }
        }
        else {
            //$(gridcomp).find("tbody tr:nth-child(" + (pos + 1) + ")").before(rowHTML);            
            var node = gridcomp.querySelector("tbody.grid-body tr:nth-child(" + (pos + 1) + ")");
            node.parentNode.insertBefore(rowHTML, node);
        }
    }
    else {
        $(editrow).removeClass("active-row");
        $(editrow).removeClass("edit-row");
    }
    COMP_GRID.clearInput(gridcomp);    
}

COMP_GRID.colResize = function (gridcomp) {
    if (gridcomp != undefined && gridcomp != null) {
        if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
            gridcomp = gridcomp[0];
    }
    var $table = gridcomp.querySelector('table.scroll'),
        $bodyCells = $table.querySelector('thead tr:first-child').children,
        colWidth;

    $(window).resize(function () {
        colWidth = $($bodyCells).map(function () {
            return $(this).width();
        }).get();

        var colLEn = colWidth.length;
        var trcount = 0;

        $($table.querySelectorAll('tbody.grid-body tr')).children("td").each(function (i, v) {
            if (trcount == colLEn)
                trcount = 0;            
            $(this).width(colWidth[trcount] - 3);
            $(this).css("max-width", colWidth[trcount] - 3);
            //$(v).css("min-width", colWidth[trcount] - 3);
            trcount++;
        });
    }).resize();
}

COMP_GRID.GoToPage = function (gridcomp,pos) {
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
        COMP_GRID.addNewRow(gridcomp, elem, '', true, rowindex);
        rowindex++;
    });
    COMP_GRID.colResize(gridcomp);
    // Hide Extra page number - dot-page
    try {
        $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).removeClass("active-page");
        $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).hide();
    }
    catch (e) { }

    $(gridcomp.querySelectorAll("tfoot tr th ul li")).removeClass("active-page");
    $(gridcomp.querySelectorAll("tfoot tr th ul li.page-text")).text('Page ' + (gridcomp.currentPage) + ' of ' + maxPageSize);
    var pageLi = $(gridcomp.querySelector("tfoot tr th ul li[page='" + gridcomp.currentPage + "']"));
    if (pageLi.length > 0) {
        $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).removeClass("active-page");
        $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).hide();
        pageLi.addClass("active-page");
    }
    else {
        gridcomp.querySelector("tfoot tr th ul li.dot-page-number").classList.add("active-page");
        gridcomp.querySelector("tfoot tr th ul li.dot-page-number").innerHTML = gridcomp.currentPage;
        $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).show();
    }
    if (gridcomp.currentPage == 1) {
        $(gridcomp.querySelector("[type='P']")).css("cursor", "not-allowed");
    }
    else if (gridcomp.currentPage == maxPageSize) {
        $(gridcomp.querySelector("[type='N']")).css("cursor", "not-allowed");
    }
}

COMP_GRID.dynamicSort = function (property) {
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

COMP_GRID.sortgrid = function (elem) {
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
        rowDATA = rowDATA.sort(COMP_GRID.dynamicSort(key));
    else
        rowDATA = rowDATA.sort(COMP_GRID.dynamicSort("-" + key));
    gridcomp.querySelector("tbody.grid-body").innerHTML = "";
    gridcomp.currentPage = 1;
    gridcomp.rowDATA = rowDATA;
    /*for (var i = 0; i < rowDATA.length; i++) {
        rowDATA[i]["rowINDEX"] = i;
        gridcomp.rowDATA.push(rowDATA[i]);
    }
    */
    COMP_GRID.GoToPage(gridcomp, gridcomp.currentPage);
    COMP_GRID.colResize(gridcomp);
};

COMP_GRID.setRowINDEX = function (gridcomp) {

};

COMP_GRID.searchGrid = function (gridcomp, searchkey, searchval) {
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
            COMP_GRID.addNewRow(gridcomp, this, '', true, rowDATAindex);
        rowDATAindex++;
    });
    COMP_GRID.colResize(gridcomp);
}

COMP_GRID.buildPagination = function (gridcomp) {
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
    gridcomp.querySelector("tfoot tr th").innerHTML = pagination;

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
            COMP_GRID.addNewRow(gridcomp, elem, '', true, rowindex);
            rowindex++;
        });
        COMP_GRID.colResize(gridcomp);
        // Hide Extra page number - dot-page
        try {
            $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).removeClass("active-page");
            $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).hide();
        }
        catch (e) { }

        $(gridcomp.querySelectorAll("tfoot tr th ul li")).removeClass("active-page");
        $(gridcomp.querySelectorAll("tfoot tr th ul li.page-text")).text('Page ' + (gridcomp.currentPage) + ' of ' + maxPageSize);
        gridcomp.querySelector("tfoot tr th ul li[page='" + gridcomp.currentPage + "']").classList.add("active-page");
        if (gridcomp.currentPage == 1) {
            $(gridcomp.querySelector("[type='P']")).css("cursor", "not-allowed");
        }
        else if (gridcomp.currentPage == maxPageSize) {
            $(gridcomp.querySelector("[type='N']")).css("cursor", "not-allowed");
        }
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


COMP_GRID.extend = {
    /*  Sets the given values to the data adding row  */
    getRowProp: function () {

    },
    setInput: function (data) {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        //$(gridcomp).clearInput();
        COMP_GRID.clearInput(gridcomp);
        if (data == {} || data == null)
            return;
        var Objkeys = Object.keys(data);
        for (var i = 0; i < Objkeys.length; i++) {
            $(gridcomp.querySelector("tr.add-row input[key='" + Objkeys[i] + "']")).val(data[Objkeys[i]]);
        }
    },
    /*  gets the rowdata of the index position */
    getRowDATA: function (pos) {
        pos = $.isNumeric(pos) ? (pos >= 0 ? pos : -1) : -1;
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        if (pos >= 0 && pos <= gridcomp.rowDATA.length - 1)
            return gridcomp.rowDATA[pos];
        else
            return {};
    },
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
            scrollHeight = options.scrollHeight || 320;
        if (options.DataBody.length > 1000 && options.isPagination == true)
        
        DataHead = DataHead || [];
        DataBody = DataBody || [];
        gridcomp.headDATA = DataHead;
        try {
            if ($.isNumeric(paginationSize) && paginationSize > 100) { alert("Max PageLength is 100 rows per Page"); }
        } catch (e) { }
        gridcomp.paginationSIZE = $.isNumeric(paginationSize) ? (paginationSize == 0 ? 10 : (paginationSize > 100 ? 100 : paginationSize)) : 10;
        gridcomp.isPagination = isPagination;
        if (!isPagination)
            gridcomp.paginationSIZE = DataBody.length;
        var _pagesize = gridcomp.paginationSIZE;
        var searchTR = "<tr class='search-tr'>";
        var thead = "<tr class='thead-tr'>";
        var theadAddRow = "";
        var tbody = "<tr class='grid-row'>";
        var EnterImg = "<img class='enter-icon' src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAA3NCSVQICAjb4U/gAAAACXBIWXMAAAB0AAAAdAExheWBAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAEJQTFRF////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhihLswAAABV0Uk5TAAcRMEhMXmBiZWp4g4qYq83U5/f+Viz5HgAAAFRJREFUGJWFj9sOgCAMQysbXifidP//qz4IhECM5/EkbVo4USuoOEhkKnAUKKOCFUa1IPsW29gIf81JHOHlvD1AhjU0IlMimX1Kpcvwt6Ob3p1r7z9ugQZkpy4T1gAAAABJRU5ErkJggg==' />";
        for (var i = 0; i < DataHead.length; i++) {
            var hidden = DataHead[i].hidden || false;
            var type = DataHead[i].type || "text";
            type = type.toLowerCase();
            var inputType = "text";

            thead += "<th key='" + DataHead[i].key + "'> " +
                        " <div title='Sort rows' sorted='' key='" + DataHead[i].key + "' onclick='COMP_GRID.sortgrid(this);' class='grid-sortkey'><span class='grid-up'>&#9650</span><span class='grid-down'>&#9660</span></div> " +
                        "<p title='" + DataHead[i].label + "' class='lbl'>" + DataHead[i].label + "</p>" +
                        " <span title='search' class='grid-search'> &#128270;</span> " +
                        "</th>";
            tbody += "<td key='" + DataHead[i].key + "'></td>";
            var img = i == DataHead.length - 1 ? EnterImg : "";

            if (type == "text")
                inputType = "text";
            else if (type == "help")
                inputType = "text";
            else if (type == "date")
                inputType = "text";
            else
                inputType = "text";
            theadAddRow += "<th><input HeadIndex='" + i + "' OrgType='" + type + "' type='" + inputType + "' key='" + DataHead[i].key + "'/>" + img + "</th>";
            searchTR += "<th><input type='text' placeholder='search..' key='" + DataHead[i].key + "'/></th>";
        }
        thead += "</tr><tr class='add-row'>" + theadAddRow + "</tr>";
        tbody += "</tr>";
        try {
            $(gridcomp).prop("rowHTML", tbody);
            gridcomp.rowHTML = tbody;
            $(gridcomp).prop("searchTR", searchTR);
        } catch (e) { }
        gridcomp.querySelector("table.comp-grid-table thead").innerHTML = thead;

        for (var j = 0; j < DataBody.length ; j++) {
            DataBody[j]["rowINDEX"] = j;
            if (j < _pagesize)
                COMP_GRID.addNewRow(gridcomp, DataBody[j]);
            else
                gridcomp.rowDATA.push(DataBody[j]);
        }
        COMP_GRID.colResize(gridcomp);
        if (!isPagination)
            gridcomp.querySelector("tfoot").remove();
        else
            COMP_GRID.buildPagination(gridcomp);
       
        $(gridcomp).find(".add-row th input[OrgType='help']").focusin(function (e) {
            var len = $(this).parent("th").find('.help-div').length;
            if (len > 0)
                return;
            var headIndex = $(this).attr("headindex");
            var HeadData = gridcomp.headDATA[headIndex];
            $(this).attr("placeholder", "Loading Help..");
            var Query = HeadData.Query || { ProcedureName: "", Type: "T", Parameters: ["SELECT LedPk as AcCd  FROM LosLead(NOLOCK); "] };
            COMP_GRID.CallWebService("HELP", Query, COMP_GRID.CallBack, "MULTI", [this, HeadData]);
        });

        $(gridcomp).find(".add-row th input[OrgType='help']").focusout(function (e) {
            var HelpDiv = $(this).parent("th").find('.help-div');
            $(this).attr("placeholder", "");
            var len = HelpDiv.length;
            if (len == 0)
                return;
            setTimeout(function () { $(HelpDiv).remove(); }, 200);
        });

        $(gridcomp).find(".thead-tr th").mouseover(function (e) {
            var elem = this;
            $(gridcomp).find("[sorted=''] .grid-up").css("visibility", "hidden");
            $(gridcomp).find("[sorted=''] .grid-down").css("visibility", "hidden");

            var sorted = $(elem).find(".grid-sortkey").attr("sorted");
            if (sorted == "ASC") {
                $(elem).find(".grid-up").css("visibility", "visible");
                $(elem).find(".grid-down").css("visibility", "hidden");
            }
            else if (sorted == "DES") {
                $(elem).find(".grid-up").css("visibility", "hidden");
                $(elem).find(".grid-down").css("visibility", "visible");
            }
            else {
                $(elem).find(".grid-up").css("visibility", "visible");
                $(elem).find(".grid-down").css("visibility", "visible");
            }
        });
        $(gridcomp).find(".thead-tr th").mouseleave(function (e) {
            var elem = this;
            $(gridcomp).find("[sorted=''] .grid-up").css("visibility", "hidden");
            $(gridcomp).find("[sorted=''] .grid-down").css("visibility", "hidden");

            var sorted = $(elem).find(".grid-sortkey").attr("sorted");
            if (sorted == "ASC") {
                $(elem).find(".grid-up").css("visibility", "visible");
                $(elem).find(".grid-down").css("visibility", "hidden");
            }
            else if (sorted == "DES") {
                $(elem).find(".grid-up").css("visibility", "hidden");
                $(elem).find(".grid-down").css("visibility", "visible");
            }
            else {
                $(elem).find(".grid-up").css("visibility", "hidden");
                $(elem).find(".grid-down").css("visibility", "hidden");
            }
        });

        $(gridcomp).find(".grid-search").click(function (e) {
            if ($(gridcomp).find("thead tr.search-tr").length > 0) {
                $(gridcomp).find("thead tr.search-tr").remove();
            }
            else {
                var sTR = $(gridcomp).prop("searchTR");
                $(gridcomp).find("thead tr:nth-child(1)").after(sTR);
                $("comp-grid thead tr.search-tr input").keydown(function (e) {                    
                    var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
                    if (keyCode != 13)
                        return;
                    var searchtext = $(this).val();
                    var searchkey = $(this).attr("key");
                    if (searchtext.trim() != "")
                        COMP_GRID.searchGrid(gridcomp, searchkey, searchtext);
                    else
                        COMP_GRID.GoToPage(gridcomp, gridcomp.currentPage);
                });
            }
        });
        $(gridcomp.querySelector("table.comp-grid-table tbody.grid-body")).css("height", scrollHeight);
        gridcomp.isInitiaziled = true;
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
            COMP_GRID.addNewRow(gridcomp, elem, '', true);
        });
        COMP_GRID.colResize(gridcomp);
    },
    /*  edit the rowdata of the index position */
    editRow: function (pos, datapos) {
        pos = $.isNumeric(pos) ? (pos >= 0 ? pos : -1) : -1;
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        if (pos >= 0 && pos <= gridcomp.rowDATA.length - 1) {
            var rowdata = $(gridcomp).getRowDATA(pos);
            $(gridcomp).setInput(rowdata);
        }
        COMP_GRID.colResize(gridcomp);
        $(gridcomp).find(".comp-grid-table thead th:first-child input").focus();
    },
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
        COMP_GRID.clearInput(gridcomp);
        COMP_GRID.colResize(gridcomp);
    },
    deleteRow: function (pos) {
        pos = $.isNumeric(pos) ? (pos >= 0 ? pos : -1) : -1;
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, curPage = gridcomp.currentPage,
           maxPageSize = Math.ceil(rowDATA.length / pageLength);
        if (pos != -1) {
            $(gridcomp).find("tbody.grid-body tr[rowindex='" + pos + "']").remove();
            var delpos = pos;
            gridcomp.rowDATA.splice(delpos, 1);
        }
        COMP_GRID.colResize(gridcomp);
    },
    getGridData: function () {
        var gridcomp = this;
        if (gridcomp != undefined && gridcomp != null) {
            if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                gridcomp = gridcomp[0];
        }
        return gridcomp.rowDATA;
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
                COMP_GRID.addNewRow(gridcomp, elem, '', true, rowindex);
                rowindex++;
            });
            COMP_GRID.colResize(gridcomp);
            if (gridcomp.currentPage < maxPageSize)
                gridcomp.currentPage++;
            $(gridcomp.querySelectorAll("tfoot tr th ul li")).removeClass("active-page");
            $(gridcomp.querySelectorAll("tfoot tr th ul li.page-text")).text('Page ' + gridcomp.currentPage + ' of ' + maxPageSize);

            if ($(gridcomp.querySelector("tfoot tr th ul li[page='" + gridcomp.currentPage + "']")).length > 0) {
                $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).removeClass("active-page");
                $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).hide();
                gridcomp.querySelector("tfoot tr th ul li[page='" + gridcomp.currentPage + "']").classList.add("active-page");
            }
            else {
                gridcomp.querySelector("tfoot tr th ul li.dot-page-number").classList.add("active-page");
                gridcomp.querySelector("tfoot tr th ul li.dot-page-number").innerHTML = gridcomp.currentPage;
                $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).show();
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
                COMP_GRID.addNewRow(gridcomp, elem, '', true, rowindex);
                rowindex++;
            });
            COMP_GRID.colResize(gridcomp);
            $(gridcomp.querySelectorAll("tfoot tr th ul li")).removeClass("active-page");
            $(gridcomp.querySelectorAll("tfoot tr th ul li.page-text")).text('Page ' + (gridcomp.currentPage - 1) + ' of ' + maxPageSize);
            if (gridcomp.currentPage > 1)
                gridcomp.currentPage--;
            if ($(gridcomp.querySelector("tfoot tr th ul li[page='" + gridcomp.currentPage + "']")).length > 0) {
                $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).removeClass("active-page");
                $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).hide();
                gridcomp.querySelector("tfoot tr th ul li[page='" + gridcomp.currentPage + "']").classList.add("active-page");
            }
            else {
                gridcomp.querySelector("tfoot tr th ul li.dot-page-number").classList.add("active-page");
                gridcomp.querySelector("tfoot tr th ul li.dot-page-number").innerHTML = gridcomp.currentPage;
                $(gridcomp.querySelector("tfoot tr th ul li.dot-page-number")).show();
            }
            if (gridcomp.currentPage == 1) {
                $(gridcomp.querySelector("[type='P']")).css("cursor", "not-allowed");
            }
        }
    }
};


$.fn.extend(COMP_GRID.extend);



var createComponent_grid = function (TagName, HtmlSrc) {

    var ElementProto = Object.create(HTMLElement.prototype);

    /* DEFINITIONS */

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
        componentWidth = componentWidth == 0 ? "100%" : componentWidth;
        componentHeight = componentHeight == 0 ? "100%" : componentHeight;
        var componentID = this.getAttribute("id") || this.id || "";


        var htmltoAppend = "";

        if (HtmlSrc && HtmlSrc != "") {
            var textContent = document.querySelector("#" + HtmlSrc).import;
            htmltoAppend = textContent.querySelector("custom-component").innerHTML;
        } else {
            htmltoAppend = document.getElementById("HtmlSrc").innerHTML;
        }

        GridShadow.innerHTML = htmltoAppend;


        /* OPTIONS - EVENTS */

        $(document).on("click", ".comp-grid-table tbody.grid-body tr.grid-row", function (e) {
            var gridcomp = $(this).closest("comp-grid");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            $(this).toggleClass("active-row");
            $(this).siblings().removeClass("active-row");
            $(this).parent("tbody.grid-body").find("tr").removeClass("edit-row");
            COMP_GRID.clearInput(gridcomp);
        });

        $(document).on("dblclick", ".comp-grid-table tbody.grid-body tr.grid-row", function (e) {
            e.preventDefault();
            var gridcomp = $(this).closest("comp-grid");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            $(this).toggleClass("active-row");
            $(this).siblings().removeClass("active-row");
            $(this).toggleClass("edit-row");
            $(this).siblings().removeClass("edit-row");                        
            var index = $(this).attr("rowindex");
            index = parseInt(index);
            if ($.isNumeric(index)) {
                COMP_GRID.clearInput(gridcomp)
                $(gridcomp).editRow(index);
            }
        });

        $(document).on("click", ".comp-grid-table tfoot ul li.page-nav", function (e) {
            var type = $(this).attr("type");
            var gridcomp = $(this).closest("comp-grid");
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
        });




        $(document).on("keydown", ".comp-grid-table thead tr.add-row th input", function (e) {
            e = e || window.event;
            var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
            var gridcomp = $(this).closest("comp-grid");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            if (keyCode == 13) {
                var helpDiv = $(gridcomp).find(".help-div");                
                if (helpDiv.length > 0) {
                    var ActiveTr = $(helpDiv).find("tbody tr.active-help");
                    if (ActiveTr.length > 0) {
                        var val = $(ActiveTr).attr("val");
                        var Pk = $(ActiveTr).attr("PK");
                        $(this).val(val);
                        $(this).attr("PK", Pk);
                    }
                }

                var len = $(this).parent("th").find("img.enter-icon").length;
                if (len == 0) {
                    var thLen = $(this).parent("th").index() + 2;
                    var txtBOX = gridcomp.querySelector(".comp-grid-table thead tr.add-row th:nth-child(" + thLen + ") input");
                    $(txtBOX).focus();
                    return;
                }
                else {
                    var obj = {};
                    $(gridcomp).find("thead tr.add-row input").each(function () {
                        var key = $(this).attr("key");
                        var Pk = $(this).attr("PK");
                        var value = $(this).val();
                        obj[key] = value;
                        obj[key + "_PK"] = Pk;
                    });
                    COMP_GRID.addNewRow(gridcomp, obj)
                    COMP_GRID.colResize(gridcomp);
                    $(gridcomp).find("table.comp-grid-table thead tr.add-row th:first-child input").focus();
                }
            }
        });


        $(document).on("keydown", ".comp-grid-table tfoot th .gridgoto", function (e) {
            e = e || window.event;
            var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
            var key = e.key ? e.key : "X";
            if (!$.isNumeric(key) && keyCode > 31 && (keyCode < 48 || keyCode > 57)) {
                return false;
            }
            var gridcomp = $(this).closest("comp-grid");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            if (keyCode == 13) {
                var Txtnumber = parseInt($(this).val());
                if ($.isNumeric(Txtnumber)) {
                    var rowDATA = gridcomp.rowDATA, pageLength = gridcomp.paginationSIZE, maxPageSize = Math.ceil(rowDATA.length / pageLength);
                    if (Txtnumber > 0 && Txtnumber <= maxPageSize)
                        COMP_GRID.GoToPage(gridcomp, Txtnumber);
                }
            }
            return true;
        });

        $(document).on("click", ".comp-grid-table thead tr.add-row th:last-child .enter-icon", function (e) {
            var gridcomp = $(this).closest("comp-grid");
            if (gridcomp != undefined && gridcomp != null) {
                if (gridcomp.hasOwnProperty("length") || gridcomp.selector)
                    gridcomp = gridcomp[0];
            }
            var obj = {};
            $(gridcomp).find("thead input").each(function () {
                var key = $(this).attr("key");
                var Pk = $(this).attr("pk");
                var value = $(this).val();
                obj[key] = value;
                obj[key + "_PK"] = Pk;
            });
            COMP_GRID.addNewRow(gridcomp, obj)
            COMP_GRID.colResize(gridcomp);
            $(gridcomp).find("table.comp-grid-table thead tr th:first-child input").focus();
        });

        $(document).keydown(function (e) {
            e = e || window.event;
            var keyCode = (typeof e.which == "number") ? e.which : e.keyCode;
            //console.log(keyCode);
            var gridcomp = GridShadow;
            var gridTableBody = $(gridcomp).find(".comp-grid-table tbody.grid-body");
            //if ($(gridcomp) && $(gridcomp).is(":hover")) {
            switch (keyCode) {
                case 27: // escape
                    var helpDiv = $(gridcomp).find(".help-div");
                    if (helpDiv.length > 0) {
                        $(helpDiv).remove();                        
                    }
                    break;
                case 13: // enter
                    /* e.preventDefault();
                    var helpDiv = $(gridcomp).find(".help-div");
                    if (helpDiv.length > 0) { }
                    else{
                         var activeRow = $(gridTableBody).find("tr.active-row");
                         $(activeRow).toggleClass("active-row");
                         $(activeRow).siblings().removeClass("active-row");
                         $(activeRow).addClass("edit-row");
                         $(activeRow).siblings().removeClass("edit-row");
                         var index = $(activeRow).index();
                         if (index != -1) {
                             COMP_GRID.clearInput(gridcomp);
                             $(gridcomp).editRow(index);
                         }
                     }
                     */
                    break;
                case 46: // del
                    var activeRow = $(gridTableBody).find("tr.active-row");
                    var editRow = $(gridTableBody).find("tr.edit-row");
                    if (editRow.length > 0 || activeRow.length > 0) {
                        var actvINdex = $(activeRow).attr("rowindex");
                        var editINdex = $(editRow).attr("rowindex");
                        $(gridcomp).deleteRow(actvINdex);
                        $(gridcomp).deleteRow(editINdex);
                        COMP_GRID.clearInput(gridcomp);
                    }
                    break;
                case 38: // up
                    e.preventDefault();
                    var helpDiv = $(gridcomp).find(".help-div");
                    if (helpDiv.length > 0) {
                        var trList = $(helpDiv).find("tbody tr");
                        var activeIndex = $(helpDiv).find("tr.active-help").index();
                        var pos = activeIndex >= 0 ? activeIndex : -1;
                        console.log(pos)
                        if (pos != -1 && pos != 0) {
                            $(trList[pos - 1]).addClass("active-help");
                            $(trList[pos - 1]).siblings().removeClass("active-help");
                        }
                        else if (pos == 0 || pos == -1) {
                            $(trList[trList.length - 1]).addClass("active-help");
                            $(trList[trList.length - 1]).siblings().removeClass("active-help");
                        }
                    }
                    else {
                        var trList = $(gridTableBody).find("tr");
                        var activeIndex = $(gridTableBody).find("tr.active-row").index();
                        activeIndex = activeIndex == -1 ? $(gridTableBody).find("tr.edit-row").index() : activeIndex;
                        var pos = activeIndex >= 0 ? activeIndex : -1;
                        if (pos != -1 && pos != 0) {
                            $(trList[pos - 1]).click();
                        }
                        else if (pos == 0 || pos == -1) {
                            $(trList[trList.length - 1]).click();
                        }
                    }
                    break;

                case 40: // down
                    e.preventDefault();
                    var helpDiv = $(gridcomp).find(".help-div");
                    if (helpDiv.length > 0) {
                        var trList = $(helpDiv).find("tbody tr");
                        var activeIndex = $(helpDiv).find("tr.active-help").index();
                        var pos = activeIndex >= 0 ? activeIndex : -1;
                        console.log(pos)
                        if (pos != -1 && trList.length > pos + 1) {
                            $(trList[pos + 1]).addClass("active-help");
                            $(trList[pos + 1]).siblings().removeClass("active-help");
                        }
                        else if (trList.length <= pos + 1 || pos == -1) {
                            $(trList[0]).addClass("active-help");
                            $(trList[0]).siblings().removeClass("active-help");
                        }
                    }
                    else {
                        var trList = $(gridTableBody).find("tr");
                        var activeIndex = $(gridTableBody).find("tr.active-row").index();
                        activeIndex = activeIndex == -1 ? $(gridTableBody).find("tr.edit-row").index() : activeIndex;
                        var pos = activeIndex >= 0 ? activeIndex : -1;
                        if (pos != -1 && trList.length > pos + 1) {
                            $(trList[pos + 1]).click();
                        }
                        else if (trList.length <= pos + 1 || pos == -1) {
                            $(trList[0]).click();
                        }
                    }
                    break;
                default:
                    return;
            }
            //}           
        });


        /* OPTIONS - EVENTS */

        /* RENDER - TYPE */

        /* RENDER - TYPE */


        /* APLLY STYLES */        

        if (componentHeight == "100%") {
            //componentHeight = $(GridShadow).parent().height();
            //componentHeight = componentHeight.toString();
        }

        var componentForStyles = GridShadow.querySelector(".custom-component");
        componentHeight = componentHeight.replace("px", "");
        $(GridShadow).css({
            "float": "left",
            "width": componentWidth,
            "height": componentHeight,
            "overflow": "auto"
        });

        $(componentForStyles).css({
            "width": componentWidth,
            "height": componentHeight - 10
        });

        $(componentForStyles.querySelector(".comp-grid-table tbody")).css({
            "height": componentHeight - 100
        });        

    }
    ElementProto.detachedCallback = function () {
        /* Fired when the Element is removed */
    }
    ElementProto.attributeChangedCallback = function (attrName, oldValue, newValue) {
        //console.log(attrName + "=" + oldValue + "=" + newValue);
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

    createComponent_grid("comp-grid", "grid");