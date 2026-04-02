import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

const mockAuthService = {
  signUp: jest.fn(),
  login: jest.fn(),
  googleLogin: jest.fn(),
};

const mockAuthResponse = {
  message: 'Authentication successful',
  access_token: 'mock_token',
  user: { id: 'uuid-1', email: 'john@example.com', role: 'STUDENT' },
};

describe('AuthController', () => {
  let controller: AuthController;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [{ provide: AuthService, useValue: mockAuthService }],
    }).compile();

    controller = module.get<AuthController>(AuthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  // ── GET /auth ────────────────────────────────────────────────────────────────

  describe('checkPath (GET /auth)', () => {
    it("should return path confirmation string", async () => {
      const result = await controller.checkPath();
      expect(result).toBe("You're at the right path, continue!");
    });
  });

  // ── POST /auth/signup ────────────────────────────────────────────────────────

  describe('signUp (POST /auth/signup)', () => {
    it('should delegate to authService.signUp with correct args', async () => {
      mockAuthService.signUp.mockResolvedValue(mockAuthResponse);

      const result = await controller.signUp({
        email: 'john@example.com',
        password: 'secret123',
        role: 'STUDENT',
      });

      expect(mockAuthService.signUp).toHaveBeenCalledWith(
        'john@example.com',
        'secret123',
        'STUDENT',
      );
      expect(result).toEqual(mockAuthResponse);
    });

    it('should pass undefined role when not provided in body', async () => {
      mockAuthService.signUp.mockResolvedValue(mockAuthResponse);

      await controller.signUp({ email: 'john@example.com', password: 'secret123' });

      expect(mockAuthService.signUp).toHaveBeenCalledWith(
        'john@example.com',
        'secret123',
        undefined,
      );
    });

    it('should return whatever the service returns', async () => {
      const serviceResponse = { ...mockAuthResponse, message: 'Custom message' };
      mockAuthService.signUp.mockResolvedValue(serviceResponse);

      const result = await controller.signUp({
        email: 'john@example.com',
        password: 'secret123',
        role: 'TUTOR',
      });

      expect(result).toEqual(serviceResponse);
    });
  });

  // ── POST /auth/login ─────────────────────────────────────────────────────────

  describe('login (POST /auth/login)', () => {
    it('should delegate to authService.login with correct args', async () => {
      mockAuthService.login.mockResolvedValue(mockAuthResponse);

      const result = await controller.login({
        email: 'john@example.com',
        password: 'secret123',
      });

      expect(mockAuthService.login).toHaveBeenCalledWith('john@example.com', 'secret123');
      expect(result).toEqual(mockAuthResponse);
    });

    it('should propagate errors from the service', async () => {
      mockAuthService.login.mockRejectedValue(new Error('Service error'));

      await expect(
        controller.login({ email: 'john@example.com', password: 'wrong' }),
      ).rejects.toThrow('Service error');
    });
  });

  // ── POST /auth/google ────────────────────────────────────────────────────────

  describe('googleLogin (POST /auth/google)', () => {
    it('should delegate to authService.googleLogin with correct args', async () => {
      const googleResponse = {
        ...mockAuthResponse,
        message: 'Google Login successful!',
        user: { ...mockAuthResponse.user, full_name: 'John Doe', avatar_url: 'https://pic.url' },
      };
      mockAuthService.googleLogin.mockResolvedValue(googleResponse);

      const result = await controller.googleLogin({
        idToken: 'google_id_token_xyz',
        role: 'STUDENT',
      });

      expect(mockAuthService.googleLogin).toHaveBeenCalledWith('google_id_token_xyz', 'STUDENT');
      expect(result).toEqual(googleResponse);
    });

    it('should propagate errors from the service', async () => {
      mockAuthService.googleLogin.mockRejectedValue(new Error('Invalid Google token'));

      await expect(
        controller.googleLogin({ idToken: 'bad_token', role: 'STUDENT' }),
      ).rejects.toThrow('Invalid Google token');
    });
  });
});
