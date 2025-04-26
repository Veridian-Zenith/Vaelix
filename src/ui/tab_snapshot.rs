use std::collections::HashMap;
use std::sync::Mutex;
use std::sync::Arc;
use aes::Aes256;
use block_modes::{BlockMode, Cbc};
use block_padding::Pkcs7;
use hex::encode;
use hex::decode;
use rand::Rng;
use sha2::{Sha256, Digest};

type Aes256Cbc = Cbc<Aes256, Pkcs7>;

pub struct TabSnapshot {
    snapshots: Arc<Mutex<HashMap<String, String>>>,
    key: Vec<u8>,
}

impl TabSnapshot {
    pub fn new() -> Self {
        let mut rng = rand::thread_rng();
        let key: Vec<u8> = (0..32).map(|_| rng.gen()).collect();
        TabSnapshot {
            snapshots: Arc::new(Mutex::new(HashMap::new())),
            key,
        }
    }

    pub fn create_snapshot(&self, tab_id: &str, content: &str) -> String {
        let encrypted_content = self.encrypt(content);
        let mut snapshots = self.snapshots.lock().unwrap();
        snapshots.insert(tab_id.to_string(), encrypted_content.clone());
        encrypted_content
    }

    pub fn get_snapshot(&self, tab_id: &str) -> Option<String> {
        let snapshots = self.snapshots.lock().unwrap();
        snapshots.get(tab_id).cloned()
    }

    pub fn delete_snapshot(&self, tab_id: &str) {
        let mut snapshots = self.snapshots.lock().unwrap();
        snapshots.remove(tab_id);
    }

    fn encrypt(&self, content: &str) -> String {
        let cipher = Cbc::<Aes256, Pkcs7>::new_var(&self.key, &[]).unwrap();
        let ciphertext = cipher.encrypt_vec(content.as_bytes());
        encode(ciphertext)
    }

    fn decrypt(&self, encrypted_content: &str) -> String {
        let ciphertext = decode(encrypted_content).unwrap();
        let cipher = Cbc::<Aes256, Pkcs7>::new_var(&self.key, &[]).unwrap();
        let decrypted_content = cipher.decrypt_vec(&ciphertext).unwrap();
        String::from_utf8(decrypted_content).unwrap()
    }
}
