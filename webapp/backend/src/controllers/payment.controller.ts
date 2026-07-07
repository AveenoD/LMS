import type { Request, Response } from 'express';
import * as svc from '../services/razorpay.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import { tenantId } from './helpers.js';

export const createOrder = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.createOrder(tenantId(req)))
);

export const verify = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.verifyPayment(tenantId(req), req.body))
);

export const status = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.subscriptionStatus(tenantId(req)))
);
