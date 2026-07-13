fn subgraph_service(service, subgraph) {
    service.map_response(|response| {
        try {
            let cookie = response.headers["set-cookie"];
            if cookie != "" {
                let existing = response.context["set-cookie"];
                if existing == () { existing = []; }
                existing.push(cookie);
                response.context["set-cookie"] = existing;
            }
        } catch (err) {
           
        }
    });
}

fn supergraph_service(service) {
    service.map_response(|response| {
        let cookies = response.context["set-cookie"];
        if cookies != () {
            response.headers["set-cookie"] = cookies;
        }
    });
}

fn client_request(request) {
    print("Incoming x-jwt-payload: " + request.headers["x-jwt-payload"]);
}
