var api_url = "https://api.airtable.com/v0/appqYJalnUjUgXQfy/Customers";
var key = 'keyGahK21OkwKGoI8';

$(document).ready(function () {

    $.ajax({
        url: api_url + "?api_key=" + key + "&view=Grid%20view",
        contentType: "application/json",
        dataType: 'json',
        success: function (result) {
            console.log(result);
          //  console.log(Object.keys(result.records).length);
          //  console.log(result.records[0].fields.Name);
          //  console.log(result.records[0].fields.photo[0].url);

            for (i = 0; i < Object.keys(result.records).length; i++) {
                tabBody = document.getElementsByTagName("tbody").item(0);
                row = document.createElement("tr");
                cell1 = document.createElement("td");
                cell2 = document.createElement("td");
                cell3 = document.createElement("td");
                textnode1 = document.createTextNode(result.records[i].fields.Name);
                textnode2 = document.createTextNode(result.records[i].fields.Phone);
                if (result.records[i].fields.photo != undefined) {
                    cell3 = document.createElement("td");
                    link = document.createElement("a");
                    link.href = result.records[i].fields.photo[0].url;
                    textnode3 = document.createTextNode("Photo Link");
                    link.appendChild(textnode3);
                    cell3.appendChild(link);
                }
                cell1.appendChild(textnode1);
                cell2.appendChild(textnode2);
                row.appendChild(cell1);
                row.appendChild(cell2);
                row.appendChild(cell3);

                var cID = result.records[i].id;

                cell4 = document.createElement("td"); //cell for delete
                var deleteButton = document.createElement("button");
                deleteButton.setAttribute("class", "btn btn-danger");
                deleteButton.setAttribute("id", "delete-button");
                deleteButton.setAttribute("type", "button");
                deleteButton.innerHTML = "Delete";
                deleteButton.addEventListener("click", popup.bind(cID));
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
    if (confirm("Are you sure you want to delete this customer from the database?")) {
        var api_url = "https://api.airtable.com/v0/appqYJalnUjUgXQfy/Customers";
        var key = 'keyGahK21OkwKGoI8';
        $.ajax({
            type: "DELETE",
            url: api_url + "/" + this + "?api_key=" + key,
            success: function (result) {
                window.location = 'viewCust.html';
            }
        });

    }
}