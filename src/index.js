
import contractABI from "./abi.json";

const contractAddress = "0x3dF63F4c30339D4F6d26Caec6D1B14720D9001f1";

let web3 = new Web3(window.ethereum); //Connect using web3
let contract = new web3.eth.Contract(contractABI, contractAddress);

async function connectWallet() {
  if (window.ethereum) {

    const accounts = await window.ethereum
      .request({ method: "eth_requestAccounts" })
      .catch((err) => {
        if (err.code === 4001) {
          // EIP-1193 userRejectedRequest error.
          // If this happens, the user rejected the connection request.
          console.log("Please connect to MetaMask.");
        } else {
          console.error(err);
        }
      });
    setConnected(accounts[0]);
  } else {
    console.error("No web3 provider detected");
    document.getElementById("connectMessage").innerText =
      "No web3 provider detected. Please install MetaMask.";
  }
}

async function reportIncome(amount){
  const accounts = await web3.eth.getAccounts();

  //Call report income function
  try{
    await contract.methods.reportIncome(amount).send({ from: accounts[0] });

  } catch (error) {
    console.error("User rejected request:", error);
  }

}

async function audit_User(user){
  const auditContainer = document.getElementById("auditContainer");

  let tempAudits = [];

  tempAudits.innerHTML = "";

  tempAudits = await contract.methods.audit_User(user).call();

  const audits = [...tempAudits];
  audits.sort((a, b) => b.timestamp -a.timestamp);

  for (let i =0; i <audits.length; i++){
    const auditElement = document.createElement("div");
    auditElement.className = "audit";
  }
  
  const userIcon = document.createElement("img");
  userIcon.className = "user-icon";
  userIcon.src = `https://avatars.dicebear.com/api/human/${audits[i].author}.svg`;
  userIcon.alt = "User Icon";

  auditElement.appendChild(userIcon);

  const auditInner = document.createElement("div");
  auditInner.className = "tweet-inner";

  auditInner.innerHTML += `
        <div class="author">${shortAddress(audits[i].author)}</div>
        <div class="content">${audits[i].content}</div>`


}

//Shortens address
function shortAddress(address, startLength = 6, endLength = 4) {
  return `${address.slice(0, startLength)}...${address.slice(-endLength)}`;
}

function setConnected(address) {
  document.getElementById("userAddress").innerText =
    "Connected: " + shortAddress(address);
  document.getElementById("connectMessage").style.display = "none";
  document.getElementById("tweetForm").style.display = "block";

  //Call audit_user func
  audit_User(user);
}

document
  .getElementById("connectWalletBtn")
  .addEventListener("click", connectWallet);

  document.getElementById("tweetForm").addEventListener("submit", async (e) => {
    e.preventDefault();
    const content = document.getElementById("tweetContent").value;
    const tweetSubmitButton = document.getElementById("tweetSubmitBtn");
    tweetSubmitButton.innerHTML = '<div class="spinner"></div>';
    tweetSubmitButton.disabled = true;
    try {
      await createTweet(content);
    } catch (error) {
      console.error("Error sending tweet:", error);
    } finally {
      // Restore the original button text
      tweetSubmitButton.innerHTML = "Tweet";
      tweetSubmitButton.disabled = false;
    }
  });

