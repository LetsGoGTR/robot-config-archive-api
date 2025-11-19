#include <arpa/inet.h>
#include <netinet/in.h>
#include <plog/Appenders/ColorConsoleAppender.h>
#include <plog/Appenders/RollingFileAppender.h>
#include <plog/Formatters/TxtFormatter.h>
#include <plog/Init.h>
#include <plog/Log.h>
#include <sys/socket.h>
#include <unistd.h>

#include <filesystem>
#include <stdexcept>
#include <string>

#include "controllers/httpController.h"
#include "utils/config.h"

int main(int argc, char* argv[]) {
  // Initialize plog
  const std::string log_dir = "/var/log/workspace-controller";
  const std::string log_path = log_dir + "/server.log";
  std::filesystem::create_directories(log_dir);

  static plog::RollingFileAppender<plog::TxtFormatter> fileAppender(
      log_path.c_str(), 1024 * 1024, 3);  // 1MB, 3 files
  plog::init(plog::info, &fileAppender);
  // static plog::ColorConsoleAppender<plog::TxtFormatter> consoleAppender;
  // plog::init(plog::info, &fileAppender).addAppender(&consoleAppender);

  try {
    // Parse port from command line or use default
    int port = Config::PORT;
    if (argc > 1) {
      try {
        int parsed_port = std::stoi(argv[1]);
        if (parsed_port >= 1 && parsed_port <= 65535) {
          port = parsed_port;
        } else {
          PLOGW << "Invalid port range. Using default port " << Config::PORT;
        }
      } catch (...) {
        PLOGW << "Invalid port format. Using default port " << Config::PORT;
      }
    }

    int server = socket(AF_INET, SOCK_STREAM, 0);
    if (server < 0) {
      throw std::runtime_error("Socket failed");
    }

    int opt = 1;
    setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    sockaddr_in addr = {};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(port);

    if (bind(server, (sockaddr*)&addr, sizeof(addr)) < 0) {
      throw std::runtime_error("Bind failed");
    }
    if (listen(server, Config::LISTEN_BACKLOG) < 0) {
      throw std::runtime_error("Listen failed");
    }

    PLOGI << "Server started on port " << port;

    controllers::HttpController httpController;

    while (true) {
      try {
        sockaddr_in client_addr;
        socklen_t len = sizeof(client_addr);
        int client = accept(server, (sockaddr*)&client_addr, &len);
        if (client < 0) {
          continue;
        }

        // Extract client IP address
        char ip_str[INET_ADDRSTRLEN];
        std::string client_ip = "unknown";
        if (inet_ntop(AF_INET, &client_addr.sin_addr, ip_str, sizeof(ip_str))) {
          client_ip = ip_str;
        }

        httpController.handleRequest(client, client_ip);
        close(client);
      } catch (const std::exception& e) {
        PLOGE << "Error: " << e.what();
      }
    }

    close(server);
  } catch (const std::exception& e) {
    PLOGF << "Fatal: " << e.what();
    return 1;
  }
  return 0;
}
