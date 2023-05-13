const form = document.getElementById("login-form");

form.addEventListener("submit", (event) => {
    event.preventDefault();
    const username = form.elements.username.value;
    const password = form.elements.password.value;
    const user = {username, password};

    fetch("/rest/login/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(user)
    })
        .then(response => {
            if (response.status === 200) {
                response.json().then(token => {
                    sessionStorage.setItem('token', JSON.stringify(token));
                    window.location.href = "../mainMenu.html";
                })
            } else {
                window.location.href = response.statusText;
            }
        })
        .catch(error => {
            window.location.href = "../login/unknown.html";
        });
});
