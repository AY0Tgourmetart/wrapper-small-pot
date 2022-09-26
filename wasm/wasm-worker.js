import init, {init_threads, contribute_wasm} from "./pkg/wrapper_small_pot.js";

onmessage = async (event) => {
    const entropy = event.data;
    console.log("available threads:", navigator.hardwareConcurrency);

    await init();
    await init_threads(navigator.hardwareConcurrency);

    fetch('./initialContribution.json').then(response => {
        response.json().then(async (data) => {
            let json_string = JSON.stringify(data);
            let secrets = await Promise.all([
                sha256(entropy[0]),
                sha256(entropy[1]),
                sha256(entropy[2]),
                sha256(entropy[3]),
            ]);
            secrets = secrets.map(secret => '0x' + secret);

            console.log("start");
            let startTime = performance.now();
            let res = contribute_wasm(
                json_string,
                secrets[0],
                secrets[1],
                secrets[2],
                secrets[3],
            );
            let endTime = performance.now();

            console.log(`Contribution took ${endTime - startTime} milliseconds`)
        });
    });
}

async function sha256(message) {
    // encode as UTF-8
    const msgBuffer = new TextEncoder().encode(message);
    // hash the message
    const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
    // convert ArrayBuffer to Array
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    // convert bytes to hex string
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    return hashHex;
}
