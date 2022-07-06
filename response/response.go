package response

type HTTPServerResponse struct {
	Code    int         `json:"code"`
	Data    interface{} `json:"data"`
	Message interface{} `json:"message"`
}
