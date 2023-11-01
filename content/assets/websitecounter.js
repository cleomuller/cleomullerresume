const counterElement = document.getElementById('pagecount');

// Send a POST request to the API endpoint
fetch('https://ayqsc6dk0c.execute-api.eu-central-1.amazonaws.com/default/IncrementVisitorCounter', {
  method: 'POST',
  mode: 'cors'
})
.then(response => response.json())
.then(data => {
  // Display the visitor count in the counter element
  counterElement.textContent = data.body;
})
.catch(error => console.error(error));