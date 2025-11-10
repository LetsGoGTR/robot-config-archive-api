#pragma once

#include <string>

namespace controllers {

class HttpController {
 public:
  void handleRequest(int client);

 private:
  void sendResponse(int socket, int status, const std::string& body);
  void handleGetRequest(int client, const std::string& path);
  void handlePostRequest(int client, const std::string& path,
                         const std::string& body);
};

}  // namespace controllers
