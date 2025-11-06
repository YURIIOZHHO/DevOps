static_files = document.querySelector(".static-file");
reverse_proxy = document.querySelector(".reverse-proxy");

flag = 0;

document.querySelector(".btn").addEventListener("click", () =>  {
  if (flag === 0) {
    static_files.style.display = "none";
    reverse_proxy.style.display = "block";
    flag = 1;
  } else {
    static_files.style.display = "block";
    reverse_proxy.style.display = "none";
    flag = 0;
  }
});


