document.getElementById("sshconnect").onclick = async () => {
  try {
    const address = document.getElementById("address").value.trim();
    const port = Number(document.getElementById("port").value);
    const password = document.getElementById("password").value;

    if (!address || !password || !Number.isInteger(port)) {
      alert("Invalid input");
      return;
    }

    const response = await fetch("/api/ssh/connect", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        address,
        port,      // now a NUMBER ✅
        password
      })
    });

    const data = await response.json();

    if (!response.ok) {
      console.error(data);
      alert(data.error ?? "Request failed");
      return;
    }

    console.log("Success:", data);
  } catch (error) {
    console.error(error);
    alert("Network error");
  }
};

