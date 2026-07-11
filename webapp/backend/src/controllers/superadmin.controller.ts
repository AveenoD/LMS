import type { Request, Response } from 'express';
import * as svc from '../services/superadmin.service.js';
import * as notificationCenter from '../services/notificationCenter.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import { userId } from './helpers.js';

export const registerTenant = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.registerTenant(req.body, userId(req));
  res.status(201).json(result);
});

export const listTenants = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.listTenants());
});

export const suspendTenant = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.setTenantActive(Number(req.params.id), req.body.isActive, userId(req));
  res.json(result);
});

export const listSubscriptions = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.listSubscriptions());
});

export const expiring = asyncHandler(async (req: Request, res: Response) => {
  // req.query.days was coerced/validated by expiringQuerySchema — a real 0 is preserved
  // (previously `Number(...) || 3` silently overrode an explicit ?days=0).
  const days = req.query.days === undefined ? 3 : Number(req.query.days);
  res.json(await svc.expiringSoon(days));
});

export const analytics = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.analytics());
});

/** Broadcast a notification to coaching_admins — all institutes, or filtered by city. */
export const broadcastToAdmins = asyncHandler(async (req: Request, res: Response) => {
  const { title, body, city } = req.body;
  const result = await notificationCenter.broadcastNotification(
    { title, body, targetRole: 'coaching_admin', tenantId: null, city },
    userId(req)
  );
  res.status(201).json(result);
});
