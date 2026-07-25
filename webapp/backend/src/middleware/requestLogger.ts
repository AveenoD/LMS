import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger.js';

export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  
  // Log request details
  const method = req.method;
  const url = req.originalUrl;
  
  let reqBody = '';
  if (req.body && Object.keys(req.body).length > 0) {
    reqBody = JSON.stringify(req.body, null, 2);
  }
  
  logger.info(`[REQ] ${method} ${url}`, reqBody ? { body: req.body } : undefined);

  // Hook into res.send to capture the response body
  const originalSend = res.send;
  let resBody: any;
  
  res.send = function (body) {
    resBody = body;
    return originalSend.apply(this, arguments as any);
  };

  res.on('finish', () => {
    const duration = Date.now() - start;
    const status = res.statusCode;
    
    // Log response details
    let parsedBody;
    try {
      parsedBody = typeof resBody === 'string' ? JSON.parse(resBody) : resBody;
    } catch {
      parsedBody = resBody;
    }

    // Limit response body size to prevent huge terminal logs
    if (parsedBody && typeof parsedBody === 'object' && Array.isArray(parsedBody.data)) {
        if (parsedBody.data.length > 5) {
            parsedBody.data = [...parsedBody.data.slice(0, 5), `...${parsedBody.data.length - 5} more items`];
        }
    } else if (Array.isArray(parsedBody) && parsedBody.length > 5) {
        parsedBody = [...parsedBody.slice(0, 5), `...${parsedBody.length - 5} more items`];
    }

    const logMessage = `[RES] ${method} ${url} - ${status} (${duration}ms)`;
    
    if (status >= 400) {
      logger.error(logMessage, { response: parsedBody });
    } else {
      logger.info(logMessage, parsedBody ? { response: parsedBody } : undefined);
    }
  });

  next();
}
