fn subgraph_service(service, subgraph) {
    service.map_response(|response| {
        let cookie = response.headers["set-cookie"];
        if cookie != "" {
            let existing = response.context["set-cookie"];
            if existing == () { existing = []; }
            existing.push(cookie);
            response.context["set-cookie"] = existing;
        }
    });
}

fn supergraph_service(service) {
    service.map_response(|response| {
        let cookies = response.context["set-cookie"];
        if cookies != () {
            for cookie in cookies {
                response.headers.append("set-cookie", cookie);
            }
        }
    });
}
