import type { Request, Response } from 'express';
import * as svc from '../services/superadmin.service.js';
import asyncHandler from '../utils/asyncHandler.js';

export const registerTenant = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.registerTenant(req.body);
  res.status(201).json(result);
});

export const listTenants = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.listTenants());
});

export const suspendTenant = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.setTenantActive(Number(req.params.id), req.body.isActive);
  res.json(result);
});

export const listSubscriptions = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.listSubscriptions());
});

export const expiring = asyncHandler(async (req: Request, res: Response) => {
  const days = Number(req.query.days) || 3;
  res.json(await svc.expiringSoon(days));
});

export const analytics = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.analytics());
});
