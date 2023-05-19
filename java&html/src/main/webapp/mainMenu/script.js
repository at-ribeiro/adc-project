if (!(JSON.parse(sessionStorage.getItem("token")).role === "SU") && !(JSON.parse(sessionStorage.getItem("token")).role === "USER")) {
    document.getElementById("extraLink").style.display = "none";
}

    if(!(JSON.parse(sessionStorage.getItem("token")).role === "SU"))
    document.getElementById("google-cloud").style.display = "none";

    const headerUsername = document.getElementById("header-username");

    const username = JSON.parse(sessionStorage.getItem("token")).username;

    if (username) {
    headerUsername.textContent = `Welcome, ${username}!`;
}

    const headerRole = document.getElementById("header-role");

    const role = JSON.parse(sessionStorage.getItem("token")).role;

    if  (role){
    headerRole.textContent = `Your role: ${role}`;

    if (role === 'USER') {
    headerRole.classList.add('user');
} else if(role === 'GBO'){
    headerRole.classList.add('gbo');
} else if(role === 'GA'){
    headerRole.classList.add('ga');
} else if (role === 'GS') {
    headerRole.classList.add('gs');
} else if (role === 'SU') {
    headerRole.classList.add('su');
}


}


    const modifyUserLink = document.getElementById("modLink");

    if (JSON.parse(sessionStorage.getItem("token")).role === 'USER') {
    modifyUserLink.href = '/update/updateUser.html';
} else {
    modifyUserLink.href = '/update/updateAdmin.html';
}




    const form = document.getElementById("form");

    form.addEventListener("submit", (event) => {
    event.preventDefault();
    sessionStorage.removeItem("token");
    window.location.href = "/index.html"
})


const userCardTemplate = document.querySelector("[data-user-template]")
const userCardContainer = document.querySelector("[data-user-cards-container]")
const searchInput = document.querySelector("[data-search]")

searchInput.addEventListener('input', (e) => {
    const searchName = e.target.value;
    if (searchName.length > 0) {
        fetch(`/rest/search/?name=${username}&user=${searchName}`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json"
            }
        })
            .then(response => response.json())
            .then(data => {
                userCardContainer.innerHTML = ''; // Clear container before appending new cards
                data.forEach(person => {
                    const card = userCardTemplate.content.cloneNode(true).children[0]
                    const header = card.querySelector("[data-header]")
                    const body = card.querySelector("[data-body]")
                    header.textContent = person.email;
                    body.textContent = person.fullname;
                    userCardContainer.append(card);
                });
            });
    } else {
        while (userCardContainer.firstChild) {
            userCardContainer.removeChild(userCardContainer.firstChild);
        }
    }
});



