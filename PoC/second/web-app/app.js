document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("add-form");
  const transportSelect = document.getElementById("transport");
  const numberAInput = document.getElementById("number-a");
  const numberBInput = document.getElementById("number-b");
  const resultElement = document.getElementById("result");
  const errorElement = document.getElementById("error");

  if (!form || !transportSelect || !numberAInput || !numberBInput || !resultElement || !errorElement) {
    return;
  }

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    resultElement.textContent = "";
    errorElement.textContent = "";

    const a = Number.parseInt(numberAInput.value, 10);
    const b = Number.parseInt(numberBInput.value, 10);

    if (Number.isNaN(a) || Number.isNaN(b)) {
      errorElement.textContent = "Please enter two whole numbers.";
      return;
    }

    try {
      if (transportSelect.value === "graphql") {
        const response = await fetch("/api/graphql", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json"
          },
          body: JSON.stringify({
            query: "query Add($a: Int!, $b: Int!) { add(a: $a, b: $b) }",
            variables: { a, b }
          })
        });

        const payload = await response.json();

        if (!response.ok || payload.errors) {
          errorElement.textContent = payload.errors?.[0]?.message || "GraphQL request failed.";
          return;
        }

        resultElement.textContent = `Result: ${payload.data.add}`;
        return;
      }

      const response = await fetch("/api/add", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json"
        },
        body: JSON.stringify({ a, b })
      });

      const payload = await response.json();

      if (!response.ok) {
        errorElement.textContent = payload.error || "Request failed.";
        return;
      }

      resultElement.textContent = `Result: ${payload.result}`;
    } catch (_error) {
      errorElement.textContent = "Unable to reach the selected service.";
    }
  });
});