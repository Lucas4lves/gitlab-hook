import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'

export const handler = async ( e : APIGatewayProxyEvent ) : Promise<APIGatewayProxyResult>=> {
    const body = e.body? JSON.parse(e.body) : {}

    return {
        statusCode: 200,
        body: JSON.stringify(body)
    }
}