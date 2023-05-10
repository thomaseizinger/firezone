mod server;

use anyhow::{Context, Result};
use relay::SocketAddrExt;
use server::Server;
use tokio::net::UdpSocket;
use tracing::level_filters::LevelFilter;
use tracing::Level;
use tracing_subscriber::EnvFilter;

const MAX_UDP_SIZE: usize = 65536;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::builder()
                .with_default_directive(LevelFilter::INFO.into())
                .from_env_lossy(),
        )
        .init();

    let socket = UdpSocket::bind("0.0.0.0:3478").await?;
    let local_addr = socket.local_addr()?;

    tracing::info!("Listening on: {local_addr}");

    let mut server = Server::new(
        local_addr
            .try_into_v4_socket()
            .context("Server is not listening on IPv4")?,
    );

    let mut buf = [0u8; MAX_UDP_SIZE];

    loop {
        // TODO: Listen for websocket commands here and update the server state accordingly.
        let (recv_len, sender) = socket.recv_from(&mut buf).await?;

        if tracing::enabled!(target: "wire", Level::TRACE) {
            let hex_bytes = hex::encode(&buf[..recv_len]);
            tracing::trace!(target: "wire", r#"Input("{sender}","{}")"#, hex_bytes);
        }

        match server.handle_received_bytes(&buf[..recv_len], sender.try_into_v4_socket().unwrap()) {
            Ok(Some((response, recipient))) => {
                if tracing::enabled!(target: "wire", Level::TRACE) {
                    let hex_bytes = hex::encode(&response);
                    tracing::trace!(target: "wire", r#"Output("{recipient}","{}")"#, hex_bytes);
                }

                socket.send_to(&response, recipient).await?;
            }
            Ok(None) => {}
            Err(e) => {
                tracing::debug!("Failed to handle datagram from {sender}: {e}")
            }
        }
    }
}
