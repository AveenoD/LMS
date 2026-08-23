import type { Request, Response } from 'express';
import * as authService from '../services/auth.service.js';
import * as notificationCenter from '../services/notificationCenter.service.js';
import asyncHandler from '../utils/asyncHandler.js';
import { requireUser, userId } from './helpers.js';

export const login = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.login(req.body);
  res.json(result);
});

export const refresh = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.refresh(req.body);
  res.json(result);
});

export const me = asyncHandler(async (req: Request, res: Response) => {
  const result = await authService.me({ userId: userId(req) });
  res.json(result);
});

export const updateAvatar = asyncHandler(async (req: Request, res: Response) => {
  const user = await authService.updateAvatar({ userId: userId(req), avatarUrl: req.body.avatarUrl });
  res.json({ user });
});

export const logout = asyncHandler(async (_req: Request, res: Response) => {
  // Stateless JWT: client discards tokens. (Refresh-token blacklist is a future item.)
  res.json({ success: true });
});

export const registerDeviceToken = asyncHandler(async (req: Request, res: Response) => {
  const user = requireUser(req);
  await notificationCenter.registerDeviceToken(user.userId, user.tenantId ?? null, req.body.token, req.body.platform);
  res.json({ success: true });
});

export const unregisterDeviceToken = asyncHandler(async (req: Request, res: Response) => {
  await notificationCenter.unregisterDeviceToken(userId(req), req.body.token);
  res.json({ success: true });
});
