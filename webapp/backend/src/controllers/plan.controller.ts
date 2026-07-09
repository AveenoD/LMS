import type { Request, Response } from 'express';
import asyncHandler from '../utils/asyncHandler.js';
import { userId } from './helpers.js';
import * as svc from '../services/plan.service.js';

// ─── Public endpoint ─────────────────────────────────────────────────────────

/** GET /public/plans — used by the marketing/pricing page (active plans only) */
export const listPublicPlans = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.listPlans(true));
});

// ─── Super Admin endpoints ────────────────────────────────────────────────────

/** GET /superadmin/plans — all plans including inactive */
export const listPlans = asyncHandler(async (_req: Request, res: Response) => {
  res.json(await svc.listPlans(false));
});

/** GET /superadmin/plans/:id */
export const getPlan = asyncHandler(async (req: Request, res: Response) => {
  res.json(await svc.getPlanById(Number(req.params.id)));
});

/** POST /superadmin/plans */
export const createPlan = asyncHandler(async (req: Request, res: Response) => {
  const plan = await svc.createPlan(req.body, userId(req));
  res.status(201).json(plan);
});

/** PUT /superadmin/plans/:id */
export const updatePlan = asyncHandler(async (req: Request, res: Response) => {
  res.json(await svc.updatePlan(Number(req.params.id), req.body, userId(req)));
});

/** DELETE /superadmin/plans/:id — soft deactivate */
export const deactivatePlan = asyncHandler(async (req: Request, res: Response) => {
  res.json(await svc.deactivatePlan(Number(req.params.id), userId(req)));
});

// ─── Tenant Subscription Management (Super Admin) ────────────────────────────

/** GET /superadmin/tenants/:id/subscription */
export const getTenantSubscription = asyncHandler(async (req: Request, res: Response) => {
  res.json(await svc.getTenantSubscription(Number(req.params.id)));
});

/** PUT /superadmin/tenants/:id/subscription — assign plan + billing cycle */
export const assignPlan = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.assignPlanToTenant(Number(req.params.id), req.body, userId(req));
  res.json(result);
});
