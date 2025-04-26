use tokio::runtime::Runtime;
use reqwest::Client;
use serde_json::Value;

pub async fn query_svaklaai(prompt: &str) -> Result<String, Box<dyn std::error::Error>> {
    let rt = Runtime::new()?;
    let client = Client::new();

    let response = rt.block_on(async {
        let res = client.post("https://api.svaklaai.com/query")
            .json(&serde_json::json!({
                "prompt": prompt
            }))
            .send()
            .await?
            .json::<Value>()
            .await?;

        Ok::<String, Box<dyn std::error::Error>>(res["response"].as_str().unwrap().to_string())
    })?;

    Ok(response)
}
