import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from 'src/prisma.service';
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import * as argon2 from 'argon2';

jest.mock('argon2', () => ({
  hash: jest.fn(),
  verify: jest.fn(),
}));

jest.mock('google-auth-library', () => ({
  OAuth2Client: jest.fn().mockImplementation(() => ({
    verifyIdToken: jest.fn(),
  })),
}));

const mockPrisma = {
  profiles: {
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
};

const mockJwt = {
  sign: jest.fn().mockReturnValue('mock_access_token'),
};

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: JwtService, useValue: mockJwt },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // ── signUp ──────────────────────────────────────────────────────────────────

  describe('signUp', () => {
    const newUser = {
      id: 'uuid-1',
      email: 'john@example.com',
      password: 'hashed_password',
      role: 'STUDENT',
    };

    beforeEach(() => {
      (argon2.hash as jest.Mock).mockResolvedValue('hashed_password');
    });

    it('should create a new user and return auth tokens', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(null);
      mockPrisma.profiles.create.mockResolvedValue(newUser);

      const result = await service.signUp('john@example.com', 'secret123');

      expect(mockPrisma.profiles.findUnique).toHaveBeenCalledWith({
        where: { email: 'john@example.com' },
      });
      expect(argon2.hash).toHaveBeenCalledWith('secret123');
      expect(result).toEqual({
        message: 'Authentication successful',
        access_token: 'mock_access_token',
        user: { id: 'uuid-1', email: 'john@example.com', role: 'STUDENT' },
      });
    });

    it('should default role to STUDENT when not provided', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(null);
      mockPrisma.profiles.create.mockResolvedValue(newUser);

      await service.signUp('john@example.com', 'secret123');

      expect(mockPrisma.profiles.create).toHaveBeenCalledWith({
        data: expect.objectContaining({ role: 'STUDENT', book_price: 0 }),
      });
    });

    it('should uppercase the role before saving', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(null);
      mockPrisma.profiles.create.mockResolvedValue({ ...newUser, role: 'TUTOR' });

      await service.signUp('john@example.com', 'secret123', 'tutor');

      expect(mockPrisma.profiles.create).toHaveBeenCalledWith({
        data: expect.objectContaining({ role: 'TUTOR' }),
      });
    });

    it('should store a hashed password, never plaintext', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(null);
      mockPrisma.profiles.create.mockResolvedValue(newUser);

      await service.signUp('john@example.com', 'secret123');

      const createCall = mockPrisma.profiles.create.mock.calls[0][0];
      expect(createCall.data.password).toBe('hashed_password');
      expect(createCall.data.password).not.toBe('secret123');
    });

    it('should throw BadRequestException when email already exists', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(newUser);

      await expect(service.signUp('john@example.com', 'secret123')).rejects.toThrow(
        BadRequestException,
      );
      expect(mockPrisma.profiles.create).not.toHaveBeenCalled();
    });
  });

  // ── login ───────────────────────────────────────────────────────────────────

  describe('login', () => {
    const existingUser = {
      id: 'uuid-1',
      email: 'john@example.com',
      password: 'hashed_password',
      role: 'STUDENT',
    };

    it('should return auth tokens on valid credentials', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      (argon2.verify as jest.Mock).mockResolvedValue(true);

      const result = await service.login('john@example.com', 'secret123');

      expect(argon2.verify).toHaveBeenCalledWith('hashed_password', 'secret123');
      expect(result).toEqual({
        message: 'Authentication successful',
        access_token: 'mock_access_token',
        user: { id: 'uuid-1', email: 'john@example.com', role: 'STUDENT' },
      });
    });

    it('should throw UnauthorizedException when email is not found', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(null);

      await expect(service.login('unknown@example.com', 'secret123')).rejects.toThrow(
        UnauthorizedException,
      );
      expect(argon2.verify).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when password is incorrect', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      (argon2.verify as jest.Mock).mockResolvedValue(false);

      await expect(service.login('john@example.com', 'wrongpass')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should call verify with the stored hash, not the original password', async () => {
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);
      (argon2.verify as jest.Mock).mockResolvedValue(true);

      await service.login('john@example.com', 'secret123');

      expect(argon2.verify).toHaveBeenCalledWith('hashed_password', 'secret123');
    });
  });

  // ── googleLogin ─────────────────────────────────────────────────────────────

  describe('googleLogin', () => {
    const googlePayload = {
      email: 'google@example.com',
      name: 'Google User',
      picture: 'https://photo.url/avatar.jpg',
    };

    const getGoogleClient = () => (service as any).googleClient;

    it('should create a new user when no account exists', async () => {
      const createdUser = {
        id: 'uuid-new',
        email: 'google@example.com',
        role: 'STUDENT',
        full_name: 'Google User',
        avatar_url: 'https://photo.url/avatar.jpg',
      };
      getGoogleClient().verifyIdToken.mockResolvedValue({ getPayload: () => googlePayload });
      mockPrisma.profiles.findUnique.mockResolvedValue(null);
      mockPrisma.profiles.create.mockResolvedValue(createdUser);

      const result = await service.googleLogin('valid_token', 'STUDENT');

      expect(mockPrisma.profiles.create).toHaveBeenCalled();
      expect(mockPrisma.profiles.update).not.toHaveBeenCalled();
      expect(result.access_token).toBe('mock_access_token');
      expect(result.user.full_name).toBe('Google User');
      expect(result.user.avatar_url).toBe('https://photo.url/avatar.jpg');
    });

    it('should return tokens for an existing user without duplicating the account', async () => {
      const existingUser = {
        id: 'uuid-existing',
        email: 'google@example.com',
        role: 'STUDENT',
        full_name: 'Google User',
        avatar_url: 'https://photo.url/avatar.jpg',
      };
      getGoogleClient().verifyIdToken.mockResolvedValue({ getPayload: () => googlePayload });
      mockPrisma.profiles.findUnique.mockResolvedValue(existingUser);

      const result = await service.googleLogin('valid_token', 'STUDENT');

      expect(mockPrisma.profiles.create).not.toHaveBeenCalled();
      expect(result.access_token).toBe('mock_access_token');
    });

    it('should update profile if full_name or avatar_url is missing', async () => {
      const incompleteUser = {
        id: 'uuid-existing',
        email: 'google@example.com',
        role: 'STUDENT',
        full_name: null,
        avatar_url: null,
      };
      const updatedUser = {
        ...incompleteUser,
        full_name: 'Google User',
        avatar_url: 'https://photo.url/avatar.jpg',
      };
      getGoogleClient().verifyIdToken.mockResolvedValue({ getPayload: () => googlePayload });
      mockPrisma.profiles.findUnique.mockResolvedValue(incompleteUser);
      mockPrisma.profiles.update.mockResolvedValue(updatedUser);

      await service.googleLogin('valid_token', 'STUDENT');

      expect(mockPrisma.profiles.update).toHaveBeenCalled();
    });

    it('should throw UnauthorizedException when Google token is invalid', async () => {
      getGoogleClient().verifyIdToken.mockRejectedValue(new Error('Token invalid'));

      await expect(service.googleLogin('bad_token', 'STUDENT')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException when Google payload has no email', async () => {
      getGoogleClient().verifyIdToken.mockResolvedValue({
        getPayload: () => ({ email: null, name: 'No Email' }),
      });

      await expect(service.googleLogin('token', 'STUDENT')).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });
});
