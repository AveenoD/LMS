import type { Request, Response } from 'express';
import * as svc from '../services/student.service.js';
import * as notificationCenter from '../services/notificationCenter.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import { tenantId, userId } from './helpers.js';

export const dashboard = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.dashboard(tenantId(req), userId(req)))
);

export const listVideos = asyncHandler(async (req: Request, res: Response) =>
  res.json(
    await svc.listVideos(tenantId(req), userId(req), req.query.subjectId ? Number(req.query.subjectId) : null)
  )
);

export const videoDetail = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.videoDetail(tenantId(req), userId(req), Number(req.params.id)))
);

export const todayLive = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.todayLive(tenantId(req), userId(req)))
);

export const fees = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.fees(tenantId(req), userId(req)))
);

export const receipt = asyncHandler(async (req: Request, res: Response) =>
  res.json(await svc.receipt(tenantId(req), userId(req), Number(req.params.paymentId)))
);

export const askDoubt = asyncHandler(async (req: Request, res: Response) => {
  const chapter = typeof req.query.chapter === 'string' ? req.query.chapter : undefined;
  res.json(await svc.askDoubt(tenantId(req), userId(req), Number(req.query.teacherId), chapter));
});

/* Notifications */
export const listNotifications = asyncHandler(async (req: Request, res: Response) =>
  res.json(await notificationCenter.listMyNotifications(userId(req)))
);
export const unreadNotificationCount = asyncHandler(async (req: Request, res: Response) =>
  res.json({ count: await notificationCenter.unreadNotificationCount(userId(req)) })
);
export const markNotificationRead = asyncHandler(async (req: Request, res: Response) => {
  await notificationCenter.markNotificationRead(Number(req.params.id), userId(req));
  res.json({ success: true });
});
