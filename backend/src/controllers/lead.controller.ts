import type { Request, Response } from 'express';
import * as leadService from '../services/lead.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import ApiError from '../utils/ApiError.js';
import type { LeadStatus } from '../db/rows.js';

/** PUBLIC — marketing site submits a demo booking here. */
export const createLead = asyncHandler(async (req: Request, res: Response) => {
  const lead = await leadService.createLead(req.body);
  res.status(201).json({
    success: true,
    message: 'Thanks! Our team will contact you shortly.',
    leadId: lead.id,
  });
});

/** SUPER ADMIN — list / manage leads (in-app inbox). */
export const listLeads = asyncHandler(async (req: Request, res: Response) => {
  const status = typeof req.query.status === 'string' ? req.query.status : undefined;
  const leads = await leadService.listLeads({ status });
  res.json(leads);
});

export const unreadCount = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ count: await leadService.unreadCount() });
});

export const markRead = asyncHandler(async (req: Request, res: Response) => {
  await leadService.markRead(Number(req.params.id));
  res.json({ success: true });
});

export const updateStatus = asyncHandler(async (req: Request, res: Response) => {
  const updated = await leadService.updateStatus(Number(req.params.id), req.body.status as LeadStatus);
  if (!updated) throw ApiError.notFound('LEAD_NOT_FOUND');
  res.json(updated);
});
