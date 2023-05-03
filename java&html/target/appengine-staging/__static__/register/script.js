const form = document.getElementById("register-form");

form.addEventListener("submit", (event) => {
    event.preventDefault();
    const username = form.elements.username.value;
    const fullname = form.elements.fullname.value;
    const password = form.elements.password.value;
    const passwordV = form.elements.passwordV.value;
    const email = form.elements.email.value;
    const role = "USER";
    const state = "INACTIVE";
    const privacy = form.elements.privacy.value;

    const user = {username, fullname, password, passwordV, email, role, state, privacy};

    fetch("/rest/register/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(user)
    })
        .then(response => {
            if (response.status === 200) {
                response.text().then(username => {
                    sessionStorage.setItem('username', username);
                    window.location.href = "../index.html";
                })
            } else {
                window.location.href = response.statusText;
            }
        })
        .catch(error => {
            window.location.href = "/register/unknown.html";
        });
});
