package response

import "github.com/gofiber/fiber/v2"

type FiberRespFunc func(ctx *fiber.Ctx, data interface{}, status ...int) error

func SetFiberRespSuccessFunc(fc FiberRespFunc) {
	FiberRespSuccessFunc = fc
}
func SetFiberRespFailFunc(fc FiberRespFunc) {
	FiberRespFailFunc = fc
}

var FiberRespSuccessFunc FiberRespFunc = func(ctx *fiber.Ctx, data interface{}, status ...int) error {
	var (
		code = 200
	)
	if len(status) > 0 {
		code = status[0]
	}
	return ctx.Status(code).JSON(&HTTPServerResponse{Code: 0, Data: data})
}

var FiberRespFailFunc FiberRespFunc = func(ctx *fiber.Ctx, data interface{}, status ...int) error {
	var (
		code = 200
	)
	if len(status) > 0 {
		code = status[0]
	}
	return ctx.Status(code).JSON(&HTTPServerResponse{Code: -1, Data: data})
}
