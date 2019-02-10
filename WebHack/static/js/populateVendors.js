var api_url = "https://api.airtable.com/v0/appqYJalnUjUgXQfy/Vendors";
var key = 'keyGahK21OkwKGoI8';

$(document).ready(function () {

    $.ajax({
        url: api_url + "?api_key=" + key + "&view=Grid%20view",
        contentType: "application/json",
        dataType: 'json',
        success: function (result) {
            console.log(result);
        //    console.log(Object.keys(result.records).length);
        //    console.log(result.records[0].fields.VendorName);

            for (i = 0; i < Object.keys(result.records).length; i++) {
                tabBody = document.getElementsByTagName("tbody").item(0);
                row = document.createElement("tr");
                cell1 = document.createElement("td");
                cell2 = document.createElement("td");
                cell3 = document.createElement("td");
                textnode1 = document.createTextNode(result.records[i].fields.VendorName);
                textnode2 = document.createTextNode(result.records[i].fields.Email);
                textnode3 = document.createTextNode("$" + result.records[i].fields.TotalSales);
                cell1.appendChild(textnode1);
                cell2.appendChild(textnode2);
                cell3.appendChild(textnode3);
                row.appendChild(cell1);
                row.appendChild(cell2);
                row.appendChild(cell3);

                var vID = result.records[i].id;

                cell4 = document.createElement("td"); //cell for delete
                var deleteButton = document.createElement("button");
                deleteButton.setAttribute("class", "btn btn-danger");
                deleteButton.setAttribute("id", "delete-button");
                deleteButton.setAttribute("type", "button");
                deleteButton.innerHTML = "Delete";
                deleteButton.addEventListener("click", popup.bind(vID));
                cell4.appendChild(deleteButton);

                row.appendChild(cell4);

                tabBody.appendChild(row);

            }
        },
        error: function (result) {
            console.log(result);
        }
    })

});

function popup() {
    if (confirm("Are you sure you want to delete this vendor from the database?")) {

        $.ajax({
            type: "DELETE",
            url: api_url + "/" + this + "?api_key=" + key,
            success: function (result) {
                window.location = 'viewVendors.html';
            }
        });

    }
}