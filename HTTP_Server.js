const http = require("http");
const { exec } = require("child_process");
const host = "localhost";
const port = 8000;

// AWS CONFIGURATION
const AWS = require('aws-sdk');
require("aws-sdk/lib/maintenance_mode_message").suppress = true;
AWS.config.update({
    accessKeyId: 'AKIAT3I5VVD4CPTHPGA6',
    secretAccessKey: '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',
    region: 'ap-south-1',
});
const patBucketName = 'cuedesk1-githubpat';
const patFilePath = 'githubpat.txt';
module.exports = { patBucketName, patFilePath };
// AWS CONFIGURATION END

let download_plugin = require('./Plugins_Process.js')

const requestListener = async function (req, res) {
    const headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '*'
    };

    console.log(`Request URL: ${req.url}, Method: ${req.method}`);

    if (req.method === "OPTIONS") {
        console.log("Handling OPTIONS request");
        res.writeHead(200, headers);
        res.end();
        return;
    }

    if (req.url === "/update/execute" && req.method === "GET") {
        console.log("end called");
        await download_plugin.update_config();
        res.writeHead(200, headers);
        res.end("{\"status\": true}");
    } else if (req.url === "/update/restart" && req.method === "GET") {
        console.log("restart endpoint called");
        await download_plugin.restart_homebridge();
        res.writeHead(200, headers);
        res.end("{\"status\": true}");
    }
    else if (req.url.startsWith("//update/network") && req.method === "GET") {
        console.log("network speed test endpoint called");

        // Force IPv4 and add verbose output
        // const curlCommand = "curl -4 -v -w \"%{time_total}\" -o /dev/null --connect-timeout 5 http://speedtest.ftp.otenet.gr/files/test100k.zip";
        const curlCommand = "curl -v -w \"%{time_total}\" -o /dev/null --connect-timeout 5 http://speedtest.belwue.net/100k";
        exec(curlCommand, { timeout: 10000, env: { ...process.env, PATH: '/usr/bin:/bin:/usr/sbin:/sbin' } }, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing curl: ${error.message}`);
                console.error(`stderr: ${stderr}`);
                console.error(`Exit code: ${error.code}`);
                res.writeHead(500, headers);
                res.end(JSON.stringify({ 
                    status: false, 
                    error: "Network test failed", 
                    details: stderr || error.message || "Unknown error" 
                }));
                return;
            }

            const timeSec = parseFloat(stdout);
            if (isNaN(timeSec) || timeSec <= 0) {
                console.error("Invalid time output from curl:", stdout);
                res.writeHead(500, headers);
                res.end(JSON.stringify({ status: false, error: "Invalid curl output", details: stdout }));
                return;
            }

            const timeMs = timeSec * 1000;
            const fileSizeBytes = 102400;
            const speedMbps = ((fileSizeBytes * 8) / (timeSec * 1000000)).toFixed(2);

            const response = {
                status: true,
                downloadSpeedMbps: speedMbps,
                timeMs: timeMs.toFixed(2)
            };

            console.log("Network test result:", response);
            res.writeHead(200, headers);
            res.end(JSON.stringify(response));
        });
    }
    else {
        console.log("No matching endpoint found");
        res.writeHead(200, headers);
        res.end("{\"status\": false}");
    }
};

const server = http.createServer(requestListener);
server.listen(port, () => {
    console.log(`Server is running on http://${host}:${port}`);
});
