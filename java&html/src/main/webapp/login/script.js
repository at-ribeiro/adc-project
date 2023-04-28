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
            } else if (response.status === 403) {
                window.location.href = "../login/403.html";
            } else if (response.status === 404) {
                window.location.href = "../login/404.html";
            } else if (response.status === 500) {
                window.location.href = "../login/500.html";
            }
        })
        .catch(error => {
            window.location.href = "../login/unknown.html";
        });
});
